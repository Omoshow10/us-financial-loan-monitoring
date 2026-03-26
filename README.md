# 🏦 US Financial Loan Monitoring System

> \*\*A full-stack financial risk analytics project\*\* demonstrating SQL-based portfolio analysis, Python predictive modeling, and Power BI dashboard design aligned with US financial system stability and regulatory risk frameworks.

\---

## 📌 Project Overview

This project simulates an end-to-end **loan portfolio risk monitoring system** for a US financial institution. It covers the entire analytics pipeline from raw data ingestion to executive-level dashboards, modeling real-world frameworks used by banks, credit unions, and fintech risk teams.

|Layer|Technology|Purpose|
|-|-|-|
|Data Generation|Python (NumPy, Pandas)|Synthetic FDIC-inspired loan dataset|
|Data Storage|Microsoft SQL Server 2019+|T-SQL schema, indexes, and analytical queries|
|Predictive Model|Python (scikit-learn)|Probability of Default (PD) model|
|Visualization|Power BI|4-page interactive risk dashboard|

\---

## 📊 Dashboard Pages

### Page 1 - Loan Portfolio Overview

|Metric|Description|
|-|-|
|Total Loans|Count of all active loans|
|Total Portfolio Balance|Sum of outstanding principal|
|Delinquency Rate|% of loans with any missed payment|
|Charge-Off Rate|% of loans written off as losses|
|Loan Mix by Type|Mortgage, Auto, Personal, Student, SMB, Credit Card|

### Page 2 - Risk Indicators

* **Early Delinquency Trends** - 30-59 DPD rate over origination cohorts (leading indicator)
* **High-Risk Borrower Segments** - Deep Subprime vs Subprime vs Near-Prime vs Prime
* **DTI vs Default** - Debt-to-income concentration analysis
* **Credit Score Distribution** - Performing vs defaulted loan overlap

### Page 3 - Geographic Risk Concentration

* Filled US map colored by state-level delinquency rate
* Risk tier flags: Low / Moderate / High / Critical
* Top 15 states by delinquency exposure

### Page 4 - Predictive Risk Model

* Probability of Default scores (Logistic Regression, AUC ≈ 0.82)
* Expected Loss = PD × Loan Amount
* Risk band classification: Low / Medium / High / Critical
* Top 50 highest-risk loans

\---

## 🗂 Repository Structure

```
us-financial-loan-monitoring/
├── data/
│   ├── raw/                      # Placeholder for source data
│   └── processed/
│       ├── loan\_portfolio.csv         # 5,000 synthetic loans
│       ├── loan\_portfolio\_scored.csv  # + model PD scores
│       ├── delinquency\_trends.csv     # Monthly trend rollup
│       ├── geographic\_risk.csv        # State-level risk summary
│       └── borrower\_segments.csv      # Segment-level KPIs
├── sql/
│   ├── 01\_create\_schema.sql           # DDL: tables + indexes
│   └── 02\_dashboard\_queries.sql       # KPI queries for all dashboard panels
├── python/
│   ├── generate\_data.py               # Synthetic dataset generator
│   └── risk\_model.py                  # EDA + Probability of Default model
├── powerbi/
│   ├── POWERBI\_SETUP.md               # Step-by-step dashboard build guide
│   └── LoanRisk\_theme.json            # Custom Power BI color theme
├── outputs/
│   ├── eda\_charts.png                 # 6-panel exploratory analysis
│   └── model\_performance.png          # ROC curves + confusion matrix
└── README.md
```

\---

## 🚀 Quick Start

### 1\. Clone \& Install Python Dependencies

```bash
git clone https://github.com/your-username/us-financial-loan-monitoring.git
cd us-financial-loan-monitoring
pip install -r requirements.txt
```

### 2\. Generate the Dataset \& Train the PD Model

```bash
python python/01\_data\_generation.py    # generates 5,000 loan records
python python/03\_default\_prediction.py # trains model, exports PD scores
```

Outputs to `data/processed/`:

* `loan\_portfolio.csv` - 5,000 synthetic loans with realistic risk profiles
* `loan\_portfolio\_scored.csv` - same dataset with model PD scores added

### 3\. Set Up SQL Server

The project uses **Microsoft SQL Server 2019+** (the free Express edition works). See [`docs/setup\_guide.md`](docs/setup_guide.md) for the full walkthrough.

**Quick start in SSMS:**

1. Open `sql/01\_create\_schema.sql` → Execute (F5) - creates the database and tables
2. Open `sql/03\_data\_ingestion.sql` → update the two file paths → Execute - loads the CSV data
3. Open `sql/02\_dashboard\_queries.sql` → Execute - runs all KPI queries

### 4\. SQL Scripts

|Script|Purpose|
|-|-|
|`01\_create\_schema.sql`|Creates `loan\_risk\_db` database, 3 tables, 7 indexes|
|`02\_dashboard\_queries.sql`|All KPI queries for the 4 dashboard pages|
|`03\_data\_ingestion.sql`|Loads CSV data via `BULK INSERT`, stamps model metadata|
|`04\_risk\_segmentation.sql`|Segment matrix, credit bands, watchlist, vintage analysis|

### 5\. Build Power BI Dashboard

See [`powerbi/POWERBI\_SETUP.md`](powerbi/POWERBI_SETUP.md) for full step-by-step instructions including data import, DAX measures, and visual layout.

\---

## 📈 Key Findings (Sample Portfolio)

|Metric|Value|
|-|-|
|Portfolio Size|5,000 loans|
|Total Balance|\~$710M|
|Delinquency Rate|17.0%|
|Charge-Off Rate|1.5%|
|Avg Credit Score|700|
|Model AUC (PD)|0.82|

**Top Risk Drivers:**

1. Credit score below 580 (Deep Subprime) - delinquency rate 4-5× portfolio average
2. DTI ratio above 43% - significant non-linear increase in default probability
3. Personal loans and Credit Cards - highest delinquency rates by product type
4. Geographic concentration in select Sun Belt and Rust Belt states

\---

## 🔧 Tech Stack

```
Python 3.10+
├── pandas          – data manipulation
├── numpy           – numerical simulation
├── scikit-learn    – ML modeling (LR, RF, GBM)
├── matplotlib      – charting
└── seaborn         – heatmaps

SQL
└── Microsoft SQL Server 2019+  (T-SQL, BULK INSERT, SSMS)

Power BI Desktop
└── DAX measures, custom theme, 4-page report
```

\---

## 📋 Requirements

```
pandas>=1.5.0
numpy>=1.23.0
scikit-learn>=1.2.0
matplotlib>=3.6.0
seaborn>=0.12.0
```

\---

## 📚 Data Sources \& Inspiration

This project uses **synthetic data** modeled after:

* [FDIC BankFind Suite](https://banks.fdic.gov/bankfind-suite/) — institution-level banking statistics
* [FFIEC HMDA Data](https://www.consumerfinance.gov/data-research/hmda/) — Home Mortgage Disclosure Act loan records
* [Fannie Mae Single-Family Loan Performance](https://capitalmarkets.fanniemae.com/credit-risk-transfer/single-family-credit-risk-transfer/fannie-mae-single-family-loan-performance-data) — historical mortgage performance
* Federal Reserve [Charge-Off and Delinquency Rates](https://www.federalreserve.gov/releases/chargeoff/) — national benchmarks

\---

## 📐 Risk Framework Alignment

This project aligns with standard US financial risk monitoring frameworks:

|Framework|Relevance|
|-|-|
|**Basel III / IV**|PD model, LGD estimation, Expected Loss|
|**CECL (ASC 326)**|Forward-looking credit loss provisioning|
|**FDIC CAMELS**|Asset quality component (delinquency monitoring)|
|**OCC Comptroller's Handbook**|Credit risk classification (Special Mention → Loss)|
|**CFPB Fair Lending**|Borrower segment analysis, geographic concentration|

\---

## 🤝 Contributing

Pull requests welcome. For major changes, please open an issue first.

\---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

\---

*Built to demonstrate financial risk analytics competency for roles in bank supervision, credit risk management, model validation, and fintech analytics.*

