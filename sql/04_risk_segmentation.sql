-- ============================================================
-- US Financial Loan Monitoring System
-- Script: 04_risk_segmentation.sql
-- Purpose: Borrower risk segmentation queries powering the
--          "Risk Indicators" and "High-Risk Segments" pages
--
-- COMPATIBILITY — 100% ANSI SQL
--   PostgreSQL 14+  : Run as-is
--   SQL Server 2019+: Run as-is
--
--   Where row-limiting is needed, both LIMIT (PostgreSQL) and
--   TOP (SQL Server) options are shown. Uncomment the one that
--   matches your platform.
--
-- Note: All type casts use CAST() — not the PostgreSQL-only
--       ::NUMERIC shorthand — so every query runs on both
--       platforms without modification.
-- ============================================================


-- ── 1. Full Segment Performance Matrix ────────────────────────
-- Powers the Risk Indicators heat table in Power BI
SELECT
    lp.borrower_segment,
    lp.loan_type,
    COUNT(*)                                                               AS loan_count,
    SUM(lp.loan_amount)                                                    AS total_balance,
    ROUND(AVG(lp.credit_score), 0)                                         AS avg_credit_score,
    ROUND(AVG(lp.dti_ratio) * 100, 1)                                      AS avg_dti_pct,
    ROUND(AVG(lp.annual_income), 0)                                        AS avg_income,

    -- Delinquency breakdown
    SUM(CASE WHEN lp.delinquency_status = 'Current'                                        THEN 1 ELSE 0 END) AS current_count,
    SUM(CASE WHEN lp.delinquency_status IN ('30-59 DPD','60-89 DPD','90+ DPD','Default','Charged-Off') THEN 1 ELSE 0 END) AS delinquent_count,
    SUM(CASE WHEN lp.delinquency_status IN ('Default','Charged-Off')                       THEN 1 ELSE 0 END) AS default_count,

    ROUND(
        CAST(SUM(CASE WHEN lp.delinquency_status <> 'Current' THEN 1 ELSE 0 END) AS DECIMAL(10,4))
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                                      AS delinquency_rate_pct,

    ROUND(
        CAST(SUM(CASE WHEN lp.delinquency_status IN ('Default','Charged-Off') THEN 1 ELSE 0 END) AS DECIMAL(10,4))
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                                      AS default_rate_pct,

    ROUND(AVG(rs.model_pd) * 100, 2)                                       AS avg_model_pd_pct,
    ROUND(SUM(lp.loan_amount * COALESCE(rs.model_pd, 0) * 0.45), 0)       AS expected_loss_usd

FROM loan_portfolio lp
LEFT JOIN loan_risk_scores rs ON lp.loan_id = rs.loan_id
GROUP BY lp.borrower_segment, lp.loan_type
ORDER BY default_rate_pct DESC, delinquency_rate_pct DESC;


-- ── 2. Credit Score Band Risk Table ───────────────────────────
SELECT
    CASE
        WHEN credit_score < 580  THEN '1. <580   Deep Subprime'
        WHEN credit_score < 620  THEN '2. 580-619 Subprime'
        WHEN credit_score < 660  THEN '3. 620-659 Near-Prime Low'
        WHEN credit_score < 700  THEN '4. 660-699 Near-Prime High'
        WHEN credit_score < 740  THEN '5. 700-739 Prime'
        WHEN credit_score < 780  THEN '6. 740-779 Prime Plus'
        ELSE                          '7. 780+    Super Prime'
    END                                                                    AS credit_band,
    COUNT(*)                                                               AS loans,
    ROUND(AVG(dti_ratio) * 100, 1)                                         AS avg_dti_pct,
    ROUND(AVG(loan_amount), 0)                                             AS avg_balance,
    ROUND(
        CAST(SUM(CASE WHEN delinquency_status <> 'Current' THEN 1 ELSE 0 END) AS DECIMAL(10,4))
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                                      AS delinquency_rate_pct,
    ROUND(
        CAST(SUM(CASE WHEN delinquency_status IN ('Default','Charged-Off') THEN 1 ELSE 0 END) AS DECIMAL(10,4))
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                                      AS default_rate_pct
FROM loan_portfolio
GROUP BY credit_band
ORDER BY credit_band;


-- ── 3. DTI Bucket x Credit Segment Cross-Tab ──────────────────
SELECT
    CASE
        WHEN dti_ratio < 0.28 THEN 'Low     (<28%)'
        WHEN dti_ratio < 0.36 THEN 'Moderate (28-36%)'
        WHEN dti_ratio < 0.43 THEN 'High     (36-43%)'
        ELSE                       'Critical (>43%)'
    END                                                                    AS dti_bucket,
    borrower_segment,
    COUNT(*)                                                               AS loans,
    ROUND(AVG(credit_score), 0)                                            AS avg_fico,
    ROUND(
        CAST(SUM(CASE WHEN delinquency_status <> 'Current' THEN 1 ELSE 0 END) AS DECIMAL(10,4))
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                                      AS delinquency_rate_pct
FROM loan_portfolio
GROUP BY dti_bucket, borrower_segment
ORDER BY dti_bucket, delinquency_rate_pct DESC;


-- ── 4. High-Risk Watchlist — Top 200 Loans by Model PD ────────
--
-- PostgreSQL  → keep LIMIT 200 at the bottom
-- SQL Server  → uncomment SELECT TOP 200 and remove LIMIT 200

SELECT         -- PostgreSQL
-- SELECT TOP 200  -- SQL Server: uncomment this line, comment the line above
    lp.loan_id,
    lp.state,
    lp.loan_type,
    lp.loan_amount,
    lp.credit_score,
    ROUND(lp.dti_ratio * 100, 1)                                           AS dti_pct,
    lp.delinquency_status,
    lp.days_past_due,
    lp.borrower_segment,
    rs.model_pd,
    rs.risk_band,
    ROUND(lp.loan_amount * rs.model_pd * 0.45, 0)                         AS expected_loss_usd
FROM loan_portfolio lp
JOIN loan_risk_scores rs ON lp.loan_id = rs.loan_id
WHERE rs.risk_band IN ('High','Critical')
  AND lp.delinquency_status <> 'Charged-Off'
ORDER BY rs.model_pd DESC
LIMIT 200;     -- PostgreSQL: remove this line when using SQL Server TOP 200


-- ── 5. Vintage Cohort Default Analysis ────────────────────────
SELECT
    origination_year,
    origination_quarter,
    COUNT(*)                                                               AS total_originated,
    SUM(loan_amount)                                                       AS total_balance,
    SUM(CASE WHEN delinquency_status IN ('Default','Charged-Off') THEN 1 ELSE 0 END) AS defaults,
    ROUND(
        CAST(SUM(CASE WHEN delinquency_status IN ('Default','Charged-Off') THEN 1 ELSE 0 END) AS DECIMAL(10,4))
        / NULLIF(COUNT(*), 0) * 100, 2
    )                                                                      AS cumulative_default_rate_pct,
    ROUND(AVG(credit_score), 0)                                            AS avg_fico_at_origination
FROM loan_portfolio
GROUP BY origination_year, origination_quarter
ORDER BY origination_quarter;
