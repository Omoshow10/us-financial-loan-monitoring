-- ============================================================
-- US Financial Loan Monitoring System
-- Script: 01_create_schema.sql
-- Purpose: Create all tables, constraints, and indexes
--
-- COMPATIBILITY
--   PostgreSQL 14+  : Run as-is using psql
--   SQL Server 2019+: All DDL is ANSI-compatible and runs
--                     unchanged in SQL Server. The one
--                     difference is object-drop syntax —
--                     see the SQL Server drop block below.
-- ============================================================


-- ──────────────────────────────────────────────────────────────
-- DROP EXISTING OBJECTS
-- Choose ONE block that matches your database platform.
-- ──────────────────────────────────────────────────────────────

-- (1) PostgreSQL — simple DROP IF EXISTS
DROP TABLE IF EXISTS loan_risk_scores;
DROP TABLE IF EXISTS delinquency_history;
DROP TABLE IF EXISTS loan_portfolio;

/* (2) SQL Server — uncomment this block instead of (1) above
IF OBJECT_ID('loan_risk_scores',   'U') IS NOT NULL DROP TABLE loan_risk_scores;
IF OBJECT_ID('delinquency_history','U') IS NOT NULL DROP TABLE delinquency_history;
IF OBJECT_ID('loan_portfolio',     'U') IS NOT NULL DROP TABLE loan_portfolio;
*/


-- ──────────────────────────────────────────────────────────────
-- TABLE 1: loan_portfolio  (Core fact table — one row per loan)
-- ANSI compatible: identical syntax on PostgreSQL and SQL Server
-- ──────────────────────────────────────────────────────────────
CREATE TABLE loan_portfolio (
    loan_id              VARCHAR(10)    NOT NULL,
    origination_date     DATE           NOT NULL,
    state                CHAR(2)        NOT NULL,
    loan_type            VARCHAR(20)    NOT NULL,
    loan_amount          DECIMAL(15,2)  NOT NULL,
    interest_rate        DECIMAL(6,4)   NOT NULL,   -- decimal: 0.0675 = 6.75%
    loan_term_months     INT,
    credit_score         INT            NOT NULL,
    annual_income        DECIMAL(12,2)  NOT NULL,
    dti_ratio            DECIMAL(5,3)   NOT NULL,   -- decimal: 0.35 = 35%
    borrower_segment     VARCHAR(20)    NOT NULL,   -- Prime | Near-Prime | Subprime | Deep Subprime
    delinquency_status   VARCHAR(20)    NOT NULL,   -- Current | 30-59 DPD | 60-89 DPD | 90+ DPD | Default | Charged-Off
    days_past_due        INT            DEFAULT 0,
    loss_given_default   DECIMAL(15,2)  DEFAULT 0,
    prob_of_default      DECIMAL(6,4),
    origination_year     INT,
    origination_quarter  VARCHAR(7),                -- format: 2022Q1

    CONSTRAINT pk_loan_portfolio  PRIMARY KEY (loan_id),
    CONSTRAINT chk_credit_score   CHECK (credit_score  BETWEEN 300 AND 850),
    CONSTRAINT chk_dti            CHECK (dti_ratio      BETWEEN 0   AND 1),
    CONSTRAINT chk_interest_rate  CHECK (interest_rate  BETWEEN 0   AND 1),
    CONSTRAINT chk_loan_amount    CHECK (loan_amount    > 0)
);


-- ──────────────────────────────────────────────────────────────
-- TABLE 2: delinquency_history  (Monthly snapshot for trends)
-- ANSI compatible: identical syntax on PostgreSQL and SQL Server
-- ──────────────────────────────────────────────────────────────
CREATE TABLE delinquency_history (
    snapshot_month       VARCHAR(7)     NOT NULL,   -- YYYY-MM, e.g. 2023-06
    total_loans          INT            NOT NULL,
    delinquent_loans     INT            NOT NULL,
    avg_credit_score     DECIMAL(6,2),
    total_balance        DECIMAL(18,2),
    delinquency_rate     DECIMAL(6,4),              -- 0.1704 = 17.04%

    CONSTRAINT pk_delinquency_history PRIMARY KEY (snapshot_month)
);


-- ──────────────────────────────────────────────────────────────
-- TABLE 3: loan_risk_scores  (ML model output per loan)
-- ANSI compatible: identical syntax on PostgreSQL and SQL Server
-- ──────────────────────────────────────────────────────────────
CREATE TABLE loan_risk_scores (
    loan_id              VARCHAR(10)    NOT NULL,
    model_pd             DECIMAL(6,4),              -- predicted PD, 0–1
    risk_band            VARCHAR(10),               -- Low | Medium | High | Critical
    score_date           DATE,
    model_version        VARCHAR(10),               -- e.g. GBM_v1.0

    CONSTRAINT pk_loan_risk_scores PRIMARY KEY (loan_id),
    CONSTRAINT fk_risk_loan        FOREIGN KEY (loan_id)
                                   REFERENCES loan_portfolio(loan_id)
);


-- ──────────────────────────────────────────────────────────────
-- INDEXES  (identical syntax on PostgreSQL and SQL Server)
-- ──────────────────────────────────────────────────────────────
CREATE INDEX idx_loan_state         ON loan_portfolio(state);
CREATE INDEX idx_loan_type          ON loan_portfolio(loan_type);
CREATE INDEX idx_delinquency_status ON loan_portfolio(delinquency_status);
CREATE INDEX idx_borrower_segment   ON loan_portfolio(borrower_segment);
CREATE INDEX idx_origination_year   ON loan_portfolio(origination_year);
CREATE INDEX idx_credit_score       ON loan_portfolio(credit_score);
CREATE INDEX idx_risk_band          ON loan_risk_scores(risk_band);


-- ──────────────────────────────────────────────────────────────
-- VERIFY TABLES WERE CREATED
-- ──────────────────────────────────────────────────────────────
-- PostgreSQL:
--   \dt
--
-- SQL Server:
--   SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES
--   WHERE TABLE_TYPE = 'BASE TABLE';
