-- ============================================================
-- US Financial Loan Monitoring System
-- Script: 03_data_ingestion.sql
-- Purpose: Load CSV data into the SQL tables
--
-- COMPATIBILITY
--   This script contains TWO clearly separated sections:
--
--   SECTION A — PostgreSQL  (\COPY commands via psql)
--   SECTION B — SQL Server  (BULK INSERT via SSMS or sqlcmd)
--
--   Run ONLY the section that matches your platform.
--   Do not run both.
--
-- Prerequisites: 01_create_schema.sql must have been run first.
-- Data files:    data/processed/loan_portfolio.csv
--                data/processed/loan_portfolio_scored.csv
-- ============================================================


-- ============================================================
-- SECTION A  —  PostgreSQL
-- Run these commands from psql on the command line.
-- Replace /full/path/to/ with the actual path on your machine.
-- ============================================================

-- A1. Load the main loan portfolio
\COPY loan_portfolio (
    loan_id, origination_date, state, loan_type, loan_amount,
    interest_rate, loan_term_months, credit_score, annual_income,
    dti_ratio, borrower_segment, delinquency_status, days_past_due,
    loss_given_default, prob_of_default, origination_year, origination_quarter
)
FROM '/full/path/to/us-financial-loan-monitoring/data/processed/loan_portfolio.csv'
WITH (FORMAT CSV, HEADER TRUE, NULL '');


-- A2. Load model risk scores
\COPY loan_risk_scores (loan_id, model_pd, risk_band)
FROM '/full/path/to/us-financial-loan-monitoring/data/processed/loan_portfolio_scored.csv'
WITH (FORMAT CSV, HEADER TRUE, NULL '');


-- A3. Stamp the score date and model version (PostgreSQL)
UPDATE loan_risk_scores
SET    score_date    = CURRENT_DATE,
       model_version = 'GBM_v1.0'
WHERE  score_date IS NULL;


/* ============================================================
   SECTION B  —  SQL Server
   Run this block in SSMS or sqlcmd.
   Replace C:\full\path\to\ with the actual path on your machine.
   ============================================================

-- B1. Load the main loan portfolio
BULK INSERT loan_portfolio
FROM 'C:\full\path\to\us-financial-loan-monitoring\data\processed\loan_portfolio.csv'
WITH (
    FORMAT         = 'CSV',
    FIRSTROW       = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR  = '\n',
    TABLOCK
);


-- B2. Load model risk scores
BULK INSERT loan_risk_scores
FROM 'C:\full\path\to\us-financial-loan-monitoring\data\processed\loan_portfolio_scored.csv'
WITH (
    FORMAT         = 'CSV',
    FIRSTROW       = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR  = '\n',
    TABLOCK
);


-- B3. Stamp the score date and model version (SQL Server)
UPDATE loan_risk_scores
SET    score_date    = GETDATE(),
       model_version = 'GBM_v1.0'
WHERE  score_date IS NULL;

*/  -- end Section B


-- ============================================================
-- SECTION C  —  Post-load steps (ANSI — runs on both platforms)
-- ============================================================

-- C1. Populate monthly delinquency history from loaded data
--     Uses CAST() instead of ::NUMERIC so it runs on both
--     PostgreSQL and SQL Server without modification.
INSERT INTO delinquency_history (
    snapshot_month,
    total_loans,
    delinquent_loans,
    avg_credit_score,
    total_balance,
    delinquency_rate
)
SELECT
    origination_quarter                                              AS snapshot_month,
    COUNT(*)                                                         AS total_loans,
    SUM(CASE WHEN delinquency_status <> 'Current' THEN 1 ELSE 0 END) AS delinquent_loans,
    ROUND(AVG(CAST(credit_score AS DECIMAL(6,2))), 2)                AS avg_credit_score,
    SUM(loan_amount)                                                 AS total_balance,
    ROUND(
        CAST(SUM(CASE WHEN delinquency_status <> 'Current' THEN 1 ELSE 0 END) AS DECIMAL(10,4))
        / NULLIF(COUNT(*), 0), 4
    )                                                                AS delinquency_rate
FROM loan_portfolio
GROUP BY origination_quarter
ORDER BY origination_quarter;


-- C2. Row count verification (ANSI — runs on both platforms)
SELECT 'loan_portfolio'     AS table_name, COUNT(*) AS row_count FROM loan_portfolio
UNION ALL
SELECT 'loan_risk_scores'   AS table_name, COUNT(*) AS row_count FROM loan_risk_scores
UNION ALL
SELECT 'delinquency_history' AS table_name, COUNT(*) AS row_count FROM delinquency_history;
