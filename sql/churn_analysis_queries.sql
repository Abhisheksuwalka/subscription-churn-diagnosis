-- ============================================================
-- Subscription Churn Diagnosis & Customer Health Score
-- Author: Abhishek Suwalka
-- Dataset: IBM Telco Customer Churn (7,043 customers)
-- Database: SQLite (telco_churn.db)
-- ============================================================

-- ============================================================
-- Q1: Overall Churn Rate & Revenue Impact
-- ============================================================
SELECT
    Churn,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM customers), 1) AS pct_of_total,
    ROUND(SUM(MonthlyCharges), 2) AS total_monthly_revenue,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(SUM(MonthlyCharges) * 12, 2) AS annualized_revenue
FROM customers
GROUP BY Churn
ORDER BY Churn DESC;


-- ============================================================
-- Q2: Churn Rate by Contract Type
-- ============================================================
SELECT
    Contract,
    COUNT(*) AS total_customers,
    SUM(churn_binary) AS churned_customers,
    COUNT(*) - SUM(churn_binary) AS retained_customers,
    ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END), 2)
        AS monthly_revenue_lost,
    ROUND(SUM(CASE WHEN Churn = 'Yes' THEN MonthlyCharges ELSE 0 END) * 12, 2)
        AS annual_revenue_lost
FROM customers
GROUP BY Contract
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q3: Churn Rate by Internet Service (Plan Tier Proxy)
-- ============================================================
SELECT
    InternetService,
    COUNT(*) AS total_customers,
    SUM(churn_binary) AS churned,
    ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly,
    ROUND(AVG(tenure), 1) AS avg_tenure_months,
    ROUND(AVG(services_count), 1) AS avg_services_used,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END)*12, 2)
        AS annual_rev_lost
FROM customers
GROUP BY InternetService
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q4: Tenure Profile — Churned vs. Retained
-- ============================================================
SELECT
    Churn,
    COUNT(*) AS customer_count,
    ROUND(AVG(tenure), 1) AS avg_tenure_months,
    MIN(tenure) AS min_tenure,
    MAX(tenure) AS max_tenure,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_charges,
    ROUND(AVG(TotalCharges), 2) AS avg_lifetime_value_proxy
FROM customers
GROUP BY Churn;


-- ============================================================
-- Q5: Churn Rate by Tenure Band (Lifecycle Stage)
-- ============================================================
SELECT
    tenure_band,
    COUNT(*) AS total_customers,
    SUM(churn_binary) AS churned,
    COUNT(*) - SUM(churn_binary) AS retained,
    ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END) * 12, 2)
        AS annual_rev_lost
FROM customers
GROUP BY tenure_band
ORDER BY
    CASE tenure_band
        WHEN '0-12 months'  THEN 1
        WHEN '13-24 months' THEN 2
        WHEN '25-36 months' THEN 3
        WHEN '37-48 months' THEN 4
        WHEN '49-60 months' THEN 5
        WHEN '61-72 months' THEN 6
    END;


-- ============================================================
-- Q6: Revenue At Risk — High-Risk Retained Customers
-- ============================================================
WITH high_risk_retained AS (
    -- Step 1: Find retained customers who look like churners
    -- Profile: month-to-month + no security/support + early tenure
    -- These are the three strongest churn predictors from Q2, Q3, Q5
    SELECT
        customerID,
        MonthlyCharges,
        tenure,
        Contract,
        has_security,
        tenure_band,
        InternetService
    FROM customers
    WHERE
        Churn = 'No'                         -- Still with us (retained)
        AND Contract = 'Month-to-month'      -- No commitment
        AND has_security = 'No'              -- No protection services
        AND tenure <= 24                     -- Early lifecycle stage
)
-- Step 2: Calculate revenue summary from that high-risk group
SELECT
    COUNT(*) AS high_risk_customers,
    ROUND(SUM(MonthlyCharges), 2) AS monthly_revenue_at_risk,
    ROUND(SUM(MonthlyCharges) * 12, 2) AS annual_revenue_at_risk,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly_per_customer,
    ROUND(AVG(tenure), 1) AS avg_tenure_months
FROM high_risk_retained;


-- ============================================================
-- Q7: Service Adoption Depth vs. Churn Rate
-- ============================================================
SELECT
    services_count,
    COUNT(*) AS total_customers,
    SUM(churn_binary) AS churned,
    ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly,
    ROUND(AVG(tenure), 1) AS avg_tenure_months
FROM customers
GROUP BY services_count
ORDER BY services_count ASC;


-- ============================================================
-- Q8: Payment Method vs. Churn Rate
-- ============================================================
SELECT
    PaymentMethod,
    COUNT(*) AS total_customers,
    SUM(churn_binary) AS churned,
    ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly,
    ROUND(AVG(tenure), 1) AS avg_tenure_months,
    ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END) * 12, 2)
        AS annual_rev_lost
FROM customers
GROUP BY PaymentMethod
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q9: Senior Citizen Segment — Churn & Support Patterns
-- ============================================================
SELECT
    SeniorCitizen,
    COUNT(*) AS total_customers,
    SUM(churn_binary) AS churned,
    ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly,
    ROUND(AVG(tenure), 1) AS avg_tenure_months,
    ROUND(AVG(CAST(services_count AS FLOAT)), 1) AS avg_services_used,
    SUM(CASE WHEN TechSupport = 'Yes' THEN 1 ELSE 0 END) AS count_with_tech_support,
    ROUND(
        SUM(CASE WHEN TechSupport = 'Yes' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1
    ) AS pct_with_tech_support
FROM customers
GROUP BY SeniorCitizen
ORDER BY SeniorCitizen;


-- ============================================================
-- Q9b: Senior Citizen × TechSupport Cross-Tab
-- ============================================================
SELECT
    SeniorCitizen,
    TechSupport,
    COUNT(*) AS customers,
    SUM(churn_binary) AS churned,
    ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct
FROM customers
WHERE TechSupport != 'No internet service'
GROUP BY SeniorCitizen, TechSupport
ORDER BY SeniorCitizen, churn_rate_pct DESC;


-- ============================================================
-- Q10: High-Value Churner Profiles (Above Average Revenue)
-- ============================================================
SELECT
    Contract,
    tenure_band,
    InternetService,
    has_security,
    COUNT(*) AS high_value_churners,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly,
    ROUND(SUM(MonthlyCharges), 2) AS total_monthly_lost,
    ROUND(SUM(MonthlyCharges) * 12, 2) AS annual_revenue_lost,
    ROUND(AVG(tenure), 1) AS avg_tenure,
    ROUND(AVG(TotalCharges), 2) AS avg_lifetime_value
FROM customers
WHERE
    Churn = 'Yes'
    AND MonthlyCharges > (
        SELECT AVG(MonthlyCharges) FROM customers WHERE Churn = 'Yes'
    )
GROUP BY Contract, tenure_band, InternetService, has_security
HAVING COUNT(*) >= 10
ORDER BY avg_monthly DESC
LIMIT 15;


-- ============================================================
-- Q11: Bundle Tier vs. Churn Rate
-- ============================================================
SELECT
    CASE
        WHEN services_count = 0           THEN 'Tier 0: No add-ons'
        WHEN services_count BETWEEN 1 AND 2 THEN 'Tier 1: Light (1-2)'
        WHEN services_count BETWEEN 3 AND 5 THEN 'Tier 2: Moderate (3-5)'
        WHEN services_count >= 6          THEN 'Tier 3: Power User (6+)'
    END AS bundle_tier,
    COUNT(*) AS total_customers,
    SUM(churn_binary) AS churned,
    ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(MonthlyCharges), 2) AS avg_monthly,
    ROUND(AVG(tenure), 1) AS avg_tenure_months,
    ROUND(AVG(TotalCharges), 2) AS avg_lifetime_value
FROM customers
GROUP BY bundle_tier
ORDER BY churn_rate_pct DESC;


-- ============================================================
-- Q12: Top 10 Highest-Churn Customer Profiles
-- ============================================================
WITH churn_profiles AS (
    SELECT
        Contract,
        InternetService,
        has_security,
        tenure_band,
        COUNT(*) AS total_in_profile,
        SUM(churn_binary) AS churned_in_profile,
        ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
        ROUND(AVG(MonthlyCharges), 2) AS avg_monthly,
        ROUND(SUM(MonthlyCharges * churn_binary) * 12, 2) AS annual_rev_at_risk
    FROM customers
    GROUP BY Contract, InternetService, has_security, tenure_band
    HAVING COUNT(*) >= 25
)
SELECT
    Contract,
    InternetService,
    has_security AS has_security_support,
    tenure_band,
    total_in_profile AS customers_in_group,
    churned_in_profile AS churned,
    churn_rate_pct,
    avg_monthly,
    annual_rev_at_risk
FROM churn_profiles
ORDER BY churn_rate_pct DESC
LIMIT 10;


-- ============================================================
-- Q13: CLTV by Contract Type & Churn Status
-- ============================================================
SELECT
    Contract,
    Churn,
    COUNT(*) AS customer_count,
    ROUND(AVG(TotalCharges), 2) AS avg_lifetime_value,
    ROUND(SUM(TotalCharges), 2) AS total_lifetime_revenue,
    ROUND(
        SUM(TotalCharges) * 100.0 / SUM(SUM(TotalCharges)) OVER (), 1
    ) AS pct_of_all_revenue,
    ROUND(AVG(tenure), 1) AS avg_tenure_months
FROM customers
GROUP BY Contract, Churn
ORDER BY Contract, Churn DESC;


-- ============================================================
-- Q14: Retention Curve at Key Tenure Milestones
-- ============================================================
WITH monthly_cohort AS (
    SELECT
        tenure,
        COUNT(*) AS customers_at_tenure,
        SUM(churn_binary) AS churned_at_tenure
    FROM customers
    GROUP BY tenure
),
cumulative AS (
    SELECT
        tenure,
        customers_at_tenure,
        churned_at_tenure,
        SUM(churned_at_tenure) OVER (ORDER BY tenure) AS cumulative_churned,
        SUM(customers_at_tenure) OVER (ORDER BY tenure) AS cumulative_customers
    FROM monthly_cohort
)
SELECT
    tenure AS months_with_company,
    customers_at_tenure,
    churned_at_tenure,
    cumulative_churned,
    cumulative_customers,
    ROUND(
        (cumulative_customers - cumulative_churned) * 100.0 / cumulative_customers, 1
    ) AS pct_retained_at_milestone
FROM cumulative
WHERE tenure IN (3, 6, 12, 18, 24, 36, 48, 60, 72)
ORDER BY tenure;


-- ============================================================
-- Q15: Full Revenue Risk Matrix — Lifecycle × Contract
-- ============================================================
WITH segment_metrics AS (
    SELECT
        tenure_band,
        Contract,
        COUNT(*) AS total_customers,
        SUM(churn_binary) AS churned_count,
        ROUND(SUM(churn_binary) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
        ROUND(SUM(CASE WHEN Churn='No' THEN MonthlyCharges ELSE 0 END), 2)
            AS retained_monthly_revenue,
        ROUND(SUM(CASE WHEN Churn='Yes' THEN MonthlyCharges ELSE 0 END), 2)
            AS lost_monthly_revenue
    FROM customers
    GROUP BY tenure_band, Contract
)
SELECT
    tenure_band,
    Contract,
    total_customers,
    churned_count,
    churn_rate_pct,
    retained_monthly_revenue AS current_mrr_retained,
    lost_monthly_revenue AS mrr_already_lost,
    ROUND(lost_monthly_revenue * 12, 2) AS annual_revenue_lost,
    CASE
        WHEN churn_rate_pct >= 40 THEN 'CRITICAL'
        WHEN churn_rate_pct >= 20 THEN 'HIGH RISK'
        WHEN churn_rate_pct >= 10 THEN 'MODERATE'
        ELSE 'LOW RISK'
    END AS risk_level
FROM segment_metrics
ORDER BY
    CASE tenure_band
        WHEN '0-12 months'  THEN 1
        WHEN '13-24 months' THEN 2
        WHEN '25-36 months' THEN 3
        WHEN '37-48 months' THEN 4
        WHEN '49-60 months' THEN 5
        WHEN '61-72 months' THEN 6
    END,
    churn_rate_pct DESC;