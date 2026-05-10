# 🩺 Subscription Churn Diagnosis & Customer Health Score

> **Analyzed 7,043 subscription accounts to diagnose churn patterns, segment customers into 4 behavioral archetypes, and build a Customer Health Score that identifies high-risk customers at 7.2× the churn rate of low-risk ones.**

---

## 📌 Executive Summary

A subscription company with a **26.5% churn rate** was losing **$1.67M in annualized revenue**. The root cause wasn't random — it was concentrated in specific segments that standard reporting couldn't see.

Using SQL analysis, K-Means clustering, and a weighted Customer Health Score, I pinpointed **where** churn happens, **why** it happens, and **what to do** about it — with dollar-level intervention projections.

**Top Finding:** 51.4% of Month-to-Month customers in their first year churn, accounting for $819,617 in annual revenue loss. This single segment is the highest-leverage intervention target.

---

## 🏗️ Methodology

| Step | Tool | Purpose | Output |
|:-----|:-----|:--------|:-------|
| 1. Data Cleaning | Python (Pandas) | Fix types, engineer features, remove nulls | `data/cleaned/telco_churn_final.csv` |
| 2. SQL Analysis | SQLite (15 queries) | Diagnose churn by contract, tenure, services, demographics | `sql/churn_analysis_queries.sql` |
| 3. Clustering | Python (Scikit-learn K-Means, k=4) | Segment into behavioral archetypes | `models/churn_kmeans_k4.pkl` |
| 4. Health Score | Python (weighted composite) | Score every customer's churn risk 0–100 | Column: `health_score` in final CSV |
| 5. Dashboard | Power BI | Interactive 4-page executive drill-down | `powerbi/P1_Churn_Dashboard.pbix` |
| 6. Executive Brief | Google Docs → PDF | 1-page VP-ready summary with ROI projections | `docs/Executive_Brief.pdf` |

---

## 🔍 Key Findings

### 1. The Leaky Bucket — Early-Tenure Month-to-Month Customers
- **51.4% churn rate** for Month-to-Month customers in 0–12 months (worst in the base)
- 1,994 customers in this cohort; 1,024 already churned
- Annual revenue lost from this segment alone: **$819,617**
- Fix: Convert to annual contract with a targeted incentive offer

### 2. The Hidden Lever — TechSupport for Senior Citizens
- Senior citizens churn at **50.6%** without TechSupport vs. **19.6%** with it — a **31 percentage point** difference
- 830 of 1,142 senior customers currently have no TechSupport
- A 60-day free TechSupport trial for this group could protect **~$246,452/year**

### 3. Frustrated Loyalists — Customers Who Stayed, Then Left
- Cluster of 2,849 customers averaging **13.4 months tenure**, paying **$59.39/month**
- Churning at **39.6%** — these are not impulsive cancellations; they formed an opinion
- 100% of this cluster falls in Red/Yellow risk tier
- Annual revenue at risk: **$803,223**

---

## 👥 Customer Segments Identified (K-Means, k=4)

| Segment | Size | Churn Rate | Avg Tenure | Avg Monthly | Annual Rev Lost | Primary Action |
|:--------|:----:|:----------:|:----------:|:-----------:|:---------------:|:--------------|
| Frustrated Loyalists | 2,849 | 39.6% | 13.4 mo | $59.39 | $803,223 | Win-back + contract conversion |
| New & At-Risk Customers | 965 | 48.1% | 27.5 mo | $78.91 | $439,378 | Onboarding + TechSupport trial |
| Moderate-Risk Segment | 2,120 | 11.7% | 54.4 mo | $86.62 | $256,738 | Loyalty rewards + upsell |
| High-Value Loyal Customers | 1,109 | 2.8% | 43.2 mo | $24.46 | $9,099 | Standard mgmt + upsell |

**Clustering quality:** Silhouette score = 0.30 (stable across 5 random seeds, std dev = 0.00)

---

## 🏥 Customer Health Score

A weighted composite score (0–100) built from 5 behavioral signals:

| Factor | Weight | Rationale |
|:-------|:------:|:----------|
| Tenure | 25% | Longer tenures = proven stayers |
| Contract type | 25% | Annual/2-year = committed; M2M = flight risk |
| Service depth | 20% | More services = higher switching cost |
| Payment method | 15% | Auto-pay = lower friction to cancel |
| TechSupport | 15% | Support users are stickier |

**Validation results:**

| Risk Tier | Customers | Churn Rate | Avg Score |
|:----------|:---------:|:----------:|:---------:|
| 🔴 Red (High Risk) | 3,493 | 43% | 19.15 |
| 🟡 Yellow (Medium Risk) | 2,124 | 14% | 53.45 |
| 🟢 Green (Low Risk) | 1,426 | 6% | 84.79 |

**7.2× churn rate separation** between Red and Green tiers confirms the score is predictive.

---

## 💡 Recommendations & Projected ROI

**Tiered Intervention Strategy:**

- 🔴 **Red (3,493 customers):** Personal CS call + annual contract incentive  
  → $174,650 investment → 524 customers saved → **$382,126/year protected** → **2.2× ROI**

- 🟡 **Yellow (2,124 customers):** Automated nurture + service upgrade offer  
  → Focus on bundle upsell: 6+ services customers churn at 16.6% vs. 31.2% for 3–5

- 🟢 **Green (1,426 customers):** Standard management + referral incentives

**Senior TechSupport Trial** (830 seniors, no current support):  
→ Est. 257 customers retained → **$246,452/year protected**

**Combined:** ~$628,578 annual revenue recovery against $174,650 spend

---

## 📊 Dashboard Preview

*(Power BI — 4-page interactive dashboard)*

| Page | What It Shows |
|:-----|:-------------|
| Executive Overview | KPI cards: churn rate, revenue at risk, total customers |
| Customer Segments | Cluster profiles with interactive slicer |
| Health Score Distribution | Risk tier breakdown, histogram, churn rate by tier |
| Revenue Risk & ROI | Revenue risk matrix, intervention ROI calculations |

---

## 📁 Project Structure

```
Project-1-Churn-Analysis/
├── README.md                          ← This file
├── data/
│   ├── raw/                           ← Original Kaggle CSV
│   └── cleaned/
│       ├── telco_churn_final.csv      ← Master dataset (21 cols, 7,043 rows)
│       └── telco_churn.db             ← SQLite database
├── notebooks/
│   ├── Churn_Analysis_Cleaning.ipynb  ← Step 1: Data cleaning & feature engineering
│   ├── P1_SQL_Analysis.ipynb          ← Step 2: 15 SQL queries
│   └── Python_Clustering.ipynb        ← Steps 3–4: K-Means + Health Score
├── sql/
│   └── churn_analysis_queries.sql     ← All 15 queries with business comments
├── docs/
│   ├── Executive_Brief.pdf            ← 1-page VP-ready brief
│   └── *.png                          ← Charts & dashboard screenshots
├── powerbi/
│   └── P1_Churn_Dashboard.pbix        ← 4-page interactive dashboard
└── models/
    ├── churn_kmeans_k4.pkl            ← Trained K-Means model (k=4)
    └── churn_scaler.pkl               ← Feature scaler
```

---

## 🚀 How to Run

```bash
# 1. Clone this repo
git clone <repo-url>
cd Project-1-Churn-Analysis

# 2. Create and activate virtual environment
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirement.txt

# 4. Launch Jupyter
jupyter notebook

# 5. Run notebooks in order:
#    notebooks/Churn_Analysis_Cleaning.ipynb  → generates cleaned CSVs
#    notebooks/P1_SQL_Analysis.ipynb          → runs 15 SQL queries
#    notebooks/Python_Clustering.ipynb        → runs K-Means + Health Score
```

The SQL queries in `sql/churn_analysis_queries.sql` can also be run directly against `data/cleaned/telco_churn.db` using any SQLite client (e.g., DB Browser for SQLite).

---

## 🛠️ Tech Stack

| Tool | Version | Purpose |
|:-----|:--------|:--------|
| Python | 3.9 | Core analysis language |
| Pandas | Latest | Data manipulation & cleaning |
| Scikit-learn | Latest | K-Means clustering, StandardScaler |
| Matplotlib / Seaborn | Latest | Data visualization |
| SQLite | Built-in | SQL analysis engine |
| Power BI Desktop | Latest | Interactive dashboard |

---

## 📋 Resume Bullet

> *"Analyzed 7,043 subscription accounts using SQL & Python; identified 4 churn archetypes with K-Means clustering, revealing that Month-to-Month customers in their first year churn at 51.4% — the single largest revenue drain at $819K/year. Built a Customer Health Score (0–100) achieving 7.2× churn rate separation between risk tiers. Proposed targeted retention strategy projected to recover $628K ARR against $174K spend (2.2× ROI)."*

---

## 👤 Author

**Abhishek Suwalka**  
Business Analyst Portfolio Project — May 2026  
Dataset: [IBM Telco Customer Churn](https://www.kaggle.com/datasets/blastchar/telco-customer-churn) (Kaggle)
