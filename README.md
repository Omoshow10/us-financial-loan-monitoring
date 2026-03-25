# 🏦 US Financial Loan Monitoring System

> **A full-stack financial risk analytics project** demonstrating SQL-based portfolio analysis, Python predictive modeling, and Power BI dashboard design — aligned with US financial system stability and regulatory risk frameworks.

---

## 📌 Project Overview

This project simulates an end-to-end **loan portfolio risk monitoring system** for a US financial institution. It covers the entire analytics pipeline — from raw data ingestion to executive-level dashboards — modeling real-world frameworks used by banks, credit unions, and fintech risk teams.

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Data Generation | Python (NumPy, Pandas) | Synthetic FDIC-inspired loan dataset |
| Data Storage | PostgreSQL 14+ / SQL Server 2019+ | Schema, indexes, and analytical queries |
| Predictive Model | Python (scikit-learn) | Probability of Default (PD) model |
| Visualization | Power BI | 4-page interactive risk dashboard |

---

## 📊 Dashboard Pages

### Page 1 — Loan Portfolio Overview
| Metric | Description |
|--------|-------------|
| Total Loans | Count of all active loans |
| Total Portfolio Balance | Sum of outstanding principal |
| Delinquency Rate | % of loans with any missed payment |
| Charge-Off Rate | % of loans written off as losses |
| Loan Mix by Type | Mortgage, Auto, Personal, Student, SMB, Credit Card |

### Page 2 — Risk Indicators
- **Early Delinquency Trends** — 30-59 DPD rate over origination cohorts (leading indicator)
- **High-Risk Borrower Segments** — Deep Subprime vs Subprime vs Near-Prime vs Prime
- **DTI vs Default** — Debt-to-income concentration analysis
- **Credit Score Distribution** — Performing vs defaulted loan overlap

### Page 3 — Geographic Risk Concentration
- Filled US map colored by state-level delinquency rate
- Risk tier flags: Low / Moderate / High / Critical
- Top 15 states by delinquency exposure

### Page 4 — Predictive Risk Model
- Probability of Default scores (Logistic Regression, AUC ≈ 0.82)
- Expected Loss = PD × Loan Amount
- Risk band classification: Low / Medium / High / Critical
- Top 50 highest-risk loans

---

## 🗂 Repository Structure

```
us-financial-loan-monitoring/
├── data/
│   ├── raw/                      # Placeholder for source data
│   └── processed/
│       ├── loan_portfolio.csv         # 5,000 synthetic loans
│       ├── loan_portfolio_scored.csv  # + model PD scores
│       ├── delinquency_trends.csv     # Monthly trend rollup
│       ├── geographic_risk.csv        # State-level risk summary
│       └── borrower_segments.csv      # Segment-level KPIs
├── sql/
│   ├── 01_create_schema.sql           # DDL: tables + indexes
│   └── 02_dashboard_queries.sql       # KPI queries for all dashboard panels
├── python/
│   ├── generate_data.py               # Synthetic dataset generator
│   └── risk_model.py                  # EDA + Probability of Default model
├── powerbi/
│   ├── POWERBI_SETUP.md               # Step-by-step dashboard build guide
│   └── LoanRisk_theme.json            # Custom Power BI color theme
├── outputs/
│   ├── eda_charts.png                 # 6-panel exploratory analysis
│   └── model_performance.png          # ROC curves + confusion matrix
└── README.md
```

---

## 🚀 Quick Start

### 1. Clone & Install Python Dependencies

```bash
git clone https://github.com/your-username/us-financial-loan-monitoring.git
cd us-financial-loan-monitoring
pip install -r requirements.txt
```

### 2. Generate the Dataset & Train the PD Model

```bash
python python/01_data_generation.py    # generates 5,000 loan records
python python/03_default_prediction.py # trains model, exports PD scores
```

Outputs to `data/processed/`:
- `loan_portfolio.csv` — 5,000 synthetic loans with realistic risk profiles
- `loan_portfolio_scored.csv` — same dataset with model PD scores added

### 3. Set Up the SQL Database

The project supports **PostgreSQL 14+** and **SQL Server 2019+**.
All four SQL scripts are written in ANSI SQL and run on both platforms.
See [`docs/setup_guide.md`](docs/setup_guide.md) for the complete database setup walkthrough.

**PostgreSQL (quick start):**

```bash
psql -U postgres -c "CREATE DATABASE loan_risk_db;"
psql -U postgres -d loan_risk_db -f sql/01_create_schema.sql
# Edit file paths in Section A of 03_data_ingestion.sql, then:
psql -U postgres -d loan_risk_db -f sql/03_data_ingestion.sql
psql -U postgres -d loan_risk_db -f sql/02_dashboard_queries.sql
```

**SQL Server (quick start):**

Open SSMS, create a database named `loan_risk_db`, then run:
1. `sql/01_create_schema.sql` — uncomment the SQL Server drop block
2. `sql/03_data_ingestion.sql` — run **Section B only** (BULK INSERT), update file paths
3. `sql/02_dashboard_queries.sql` — switch `LIMIT` to `TOP` where noted

### 4. SQL Script Compatibility Reference

| Script | PostgreSQL | SQL Server | Key difference |
|--------|-----------|------------|----------------|
| `01_create_schema.sql` | ✅ | ✅ | Use drop block (1) or (2) |
| `02_dashboard_queries.sql` | ✅ | ✅ | `LIMIT N` vs `TOP N` |
| `03_data_ingestion.sql` | ✅ Section A | ✅ Section B | `\COPY` vs `BULK INSERT` |
| `04_risk_segmentation.sql` | ✅ | ✅ | `LIMIT N` vs `TOP N` |

### 5. Build Power BI Dashboard

See [`powerbi/POWERBI_SETUP.md`](powerbi/POWERBI_SETUP.md) for full step-by-step instructions including CSV import, DAX measures, and visual layout.

---

## 📈 Key Findings (Sample Portfolio)

| Metric | Value |
|--------|-------|
| Portfolio Size | 5,000 loans |
| Total Balance | ~$710M |
| Delinquency Rate | 17.0% |
| Charge-Off Rate | 1.5% |
| Avg Credit Score | 700 |
| Model AUC (PD) | 0.82 |

**Top Risk Drivers:**
1. Credit score below 580 (Deep Subprime) — delinquency rate 4–5× portfolio average
2. DTI ratio above 43% — significant non-linear increase in default probability
3. Personal loans and Credit Cards — highest delinquency rates by product type
4. Geographic concentration in select Sun Belt and Rust Belt states

---

## 🔧 Tech Stack

```
Python 3.10+
├── pandas          – data manipulation
├── numpy           – numerical simulation
├── scikit-learn    – ML modeling (LR, RF, GBM)
├── matplotlib      – charting
└── seaborn         – heatmaps

SQL
├── PostgreSQL 14+   (primary development platform)
└── SQL Server 2019+ (fully supported — all scripts ANSI compatible)

Power BI Desktop
└── DAX measures, custom theme, 4-page report
```

---

## 📋 Requirements

```
pandas>=1.5.0
numpy>=1.23.0
scikit-learn>=1.2.0
matplotlib>=3.6.0
seaborn>=0.12.0
```

---

## 📚 Data Sources & Inspiration

This project uses **synthetic data** modeled after:
- [FDIC BankFind Suite](https://banks.fdic.gov/bankfind-suite/) — institution-level banking statistics
- [FFIEC HMDA Data](https://www.consumerfinance.gov/data-research/hmda/) — Home Mortgage Disclosure Act loan records
- [Fannie Mae Single-Family Loan Performance](https://capitalmarkets.fanniemae.com/credit-risk-transfer/single-family-credit-risk-transfer/fannie-mae-single-family-loan-performance-data) — historical mortgage performance
- Federal Reserve [Charge-Off and Delinquency Rates](https://www.federalreserve.gov/releases/chargeoff/) — national benchmarks

---

## 📐 Risk Framework Alignment

This project aligns with standard US financial risk monitoring frameworks:

| Framework | Relevance |
|-----------|-----------|
| **Basel III / IV** | PD model, LGD estimation, Expected Loss |
| **CECL (ASC 326)** | Forward-looking credit loss provisioning |
| **FDIC CAMELS** | Asset quality component (delinquency monitoring) |
| **OCC Comptroller's Handbook** | Credit risk classification (Special Mention → Loss) |
| **CFPB Fair Lending** | Borrower segment analysis, geographic concentration |

---

## 🤝 Contributing

Pull requests welcome. For major changes, please open an issue first.

---

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

*Built to demonstrate financial risk analytics competency for roles in bank supervision, credit risk management, model validation, and fintech analytics.*
