# Setup Guide
## US Financial Loan Monitoring System

Step-by-step instructions to get the full project running locally.
This guide covers **both PostgreSQL and SQL Server** — follow the section that matches your environment.

---

## Prerequisites

| Tool | Version | Download |
|------|---------|----------|
| **PostgreSQL** *(Option A)* | 14+ | https://www.postgresql.org/download/ |
| **SQL Server** *(Option B)* | 2019+ | https://www.microsoft.com/en-us/sql-server/sql-server-downloads |
| **SQL Server Management Studio** *(if using SQL Server)* | 19+ | https://aka.ms/ssmsfullsetup |
| Python | 3.9+ | https://www.python.org/downloads/ |
| Power BI Desktop | Latest | https://powerbi.microsoft.com/desktop |
| Git | Any | https://git-scm.com/ |

> You only need **one** of PostgreSQL or SQL Server — not both.
> All four SQL scripts are compatible with either platform.

---

## Step 1 — Clone the Repository

```bash
git clone https://github.com/YOUR_USERNAME/us-financial-loan-monitoring.git
cd us-financial-loan-monitoring
```

---

## Step 2 — Python Environment Setup

```bash
# Create and activate virtual environment (recommended)
python -m venv venv
source venv/bin/activate        # macOS / Linux
venv\Scripts\activate           # Windows

# Install dependencies
pip install -r python/requirements.txt
```

---

## Step 3 — Generate the Dataset

```bash
python python/01_data_generation.py
```

Expected output:
```
loan_portfolio.csv → 5,000 rows
Delinquency rate: 17.04%
Charge-off rate:  1.54%
Total portfolio:  $0.71B
Avg credit score: 700
```

Then run the ML model to add PD scores:

```bash
python python/03_default_prediction.py
```

Expected output:
```
Logistic Regression  AUC=0.8195
Random Forest        AUC=0.8035
Gradient Boosting    AUC=0.7655

Best model: Logistic Regression
Saved: loan_portfolio_scored.csv (5,000 rows)
```

---

## Step 4A — Database Setup (PostgreSQL)

### 4A-1. Create the database

```bash
psql -U postgres -c "CREATE DATABASE loan_risk_db;"
```

### 4A-2. Run the schema script

```bash
psql -U postgres -d loan_risk_db -f sql/01_create_schema.sql
```

Expected output:
```
CREATE TABLE
CREATE TABLE
CREATE TABLE
CREATE INDEX  (×7)
```

### 4A-3. Load the data

Open `sql/03_data_ingestion.sql` and update the two file paths in **Section A** to point to your local `data/processed/` folder.

Then run:

```bash
psql -U postgres -d loan_risk_db -f sql/03_data_ingestion.sql
```

Expected output:
```
COPY 5000
COPY 5000
UPDATE 5000
INSERT 0 24

 table_name         | row_count
--------------------+-----------
 loan_portfolio     |      5000
 loan_risk_scores   |      5000
 delinquency_history|        24
```

### 4A-4. Run the dashboard queries

```bash
psql -U postgres -d loan_risk_db -f sql/02_dashboard_queries.sql
psql -U postgres -d loan_risk_db -f sql/04_risk_segmentation.sql
```

### 4A-5. Connection string for Power BI DirectQuery (optional)

```
Host:     localhost
Port:     5432
Database: loan_risk_db
Username: postgres
```

### Troubleshooting — PostgreSQL

**Connection refused:**
```bash
# macOS
pg_ctl status -D /usr/local/var/postgresql@14

# Windows
net start postgresql-x64-14

# Linux
sudo systemctl start postgresql
```

**Permission denied on \COPY:**
Ensure the file paths in Section A of `03_data_ingestion.sql` are absolute paths, not relative.

---

## Step 4B — Database Setup (SQL Server)

### 4B-1. Create the database

Open **SQL Server Management Studio (SSMS)**, connect to your instance, then run:

```sql
CREATE DATABASE loan_risk_db;
GO
USE loan_risk_db;
GO
```

Or from the command line using sqlcmd:

```bash
sqlcmd -S localhost -E -Q "CREATE DATABASE loan_risk_db;"
sqlcmd -S localhost -E -d loan_risk_db -Q "USE loan_risk_db;"
```

### 4B-2. Run the schema script

In SSMS: File → Open → `sql/01_create_schema.sql`

Before running, uncomment **Section (2)** (the SQL Server drop block) and comment out Section (1). Then click Execute (F5).

Or from sqlcmd:

```bash
sqlcmd -S localhost -E -d loan_risk_db -i sql/01_create_schema.sql
```

Expected output:
```
(0 rows affected)   ← DROP statements
(0 rows affected)   ← CREATE TABLE ×3
(0 rows affected)   ← CREATE INDEX ×7
```

### 4B-3. Load the data

Open `sql/03_data_ingestion.sql` and update the two file paths in **Section B** to use Windows-style full paths, e.g.:

```
C:\Projects\us-financial-loan-monitoring\data\processed\loan_portfolio.csv
```

In SSMS, select only the **Section B** block (the `BULK INSERT` commands) and click Execute. Do **not** run Section A.

### 4B-4. Run the dashboard queries

In SSMS, open `sql/02_dashboard_queries.sql`.

For queries that use `LIMIT`, you need to switch to the SQL Server `TOP` syntax. Each such query has both options shown — uncomment `SELECT TOP N` and remove or comment out the `LIMIT N` line at the bottom.

Then run the script, or run individual query blocks as needed.

Repeat the same process for `sql/04_risk_segmentation.sql`.

### 4B-5. Connection string for Power BI DirectQuery (optional)

```
Server:   localhost  (or your SQL Server instance name)
Database: loan_risk_db
Auth:     Windows Authentication  (or SQL Server Authentication)
```

In Power BI: Get Data → SQL Server → enter server and database name.

### Troubleshooting — SQL Server

**Cannot connect in SSMS:**
- Confirm SQL Server service is running: open Services (services.msc), find SQL Server (MSSQLSERVER), ensure it shows Running.
- Try connecting with server name `localhost\SQLEXPRESS` if using the Express edition.

**BULK INSERT permission error:**
```sql
-- Grant bulk insert permission (run as admin):
GRANT ADMINISTER BULK OPERATIONS TO [your_login];
```

**File path not found:**
- Use the full Windows path with backslashes: `C:\Projects\...`
- SQL Server must have read permission on the folder. Right-click the folder → Properties → Security → add the SQL Server service account.

---

## Step 5 — Open the Power BI Dashboard

1. Open **Power BI Desktop**
2. **Get Data → Text/CSV** → select `data/processed/loan_portfolio_scored.csv`
3. Load the table, then create the DAX measures from `powerbi/DAX_measures.md`
4. Build the four report pages as described in `powerbi/data_model.md`

> **Connecting to live SQL database (optional):**
> Instead of loading the CSV, use **Get Data → PostgreSQL** or **Get Data → SQL Server**, enter your connection details from Step 4A-5 or 4B-5, and load the `loan_portfolio` and `loan_risk_scores` tables directly.

---

## SQL Script Compatibility Reference

| Script | PostgreSQL | SQL Server | Notes |
|--------|-----------|------------|-------|
| `01_create_schema.sql` | ✅ | ✅ | Use drop block (1) for PostgreSQL, (2) for SQL Server |
| `02_dashboard_queries.sql` | ✅ | ✅ | Switch `LIMIT N` ↔ `TOP N` for row-limiting queries |
| `03_data_ingestion.sql` | ✅ Section A | ✅ Section B | Run only your platform's section |
| `04_risk_segmentation.sql` | ✅ | ✅ | Switch `LIMIT N` ↔ `TOP N` for watchlist query |

---

## Project File Map

```
us-financial-loan-monitoring/
│
├── sql/
│   ├── 01_create_schema.sql       ← Run first: tables, indexes, constraints
│   ├── 02_dashboard_queries.sql   ← All KPI & risk queries (PostgreSQL + SQL Server)
│   ├── 03_data_ingestion.sql      ← Section A: PostgreSQL | Section B: SQL Server
│   └── 04_risk_segmentation.sql   ← Segment matrix, watchlist, vintage analysis
│
├── python/
│   ├── 01_data_generation.py      ← RUN FIRST — generates sample_loan_data
│   ├── 02_eda_analysis.py         ← Portfolio overview charts (optional)
│   ├── 03_default_prediction.py   ← RUN SECOND — trains PD model, exports scores
│   └── requirements.txt
│
├── powerbi/
│   ├── POWERBI_SETUP.md           ← Step-by-step dashboard build guide
│   ├── DAX_measures.md            ← All DAX formulas documented
│   └── LoanRisk_theme.json        ← Custom dark theme file
│
├── data/
│   └── processed/
│       ├── loan_portfolio.csv         ← Generated by Step 3
│       └── loan_portfolio_scored.csv  ← Generated by Step 3 (Power BI input)
│
├── outputs/
│   ├── eda_charts.png             ← 6-panel risk analysis chart
│   ├── portfolio_overview.png     ← 9-panel portfolio overview chart
│   └── model_performance.png      ← ROC curves + confusion matrix
│
└── docs/
    ├── setup_guide.md             ← This file
    └── methodology.md             ← Risk metric definitions & regulatory context
```
