-- Project 1: Bank Customer Churn Analysis (real Kaggle data, 10,000 customers)
-- Standard SQL: tested on SQLite, works unchanged on Snowflake/Postgres.
-- Each block starts with "-- Qn:" so scripts/run_analysis.py can run this file directly.

-- Q1: Overall churn and balance at risk
SELECT COUNT(*) AS total_customers,
       SUM(churned) AS churned_customers,
       ROUND(100.0 * SUM(churned) / COUNT(*), 1) AS churn_rate_pct,
       ROUND(SUM(balance) / 1000000.0, 1) AS total_balance_m,
       ROUND(SUM(balance * churned) / 1000000.0, 1) AS churned_balance_m
FROM customers;

-- Q2: Churn by number of products
SELECT num_products, COUNT(*) AS customers, SUM(churned) AS churned,
       ROUND(100.0 * SUM(churned) / COUNT(*), 1) AS churn_rate_pct,
       ROUND(100.0 * SUM(churned) / (SELECT SUM(churned) FROM customers), 1) AS share_of_all_churners_pct
FROM customers GROUP BY num_products ORDER BY num_products;

-- Q3: Churn by activity status x product count
SELECT CASE WHEN is_active = 1 THEN 'Active' ELSE 'Inactive' END AS activity_status,
       num_products, COUNT(*) AS customers,
       ROUND(100.0 * SUM(churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers GROUP BY activity_status, num_products ORDER BY num_products, activity_status;

-- Q4: Churn by age band
SELECT CASE WHEN age < 30 THEN '18-29' WHEN age < 40 THEN '30-39'
            WHEN age < 50 THEN '40-49' WHEN age < 60 THEN '50-59' ELSE '60+' END AS age_band,
       COUNT(*) AS customers, SUM(churned) AS churned,
       ROUND(100.0 * SUM(churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers GROUP BY age_band ORDER BY age_band;

-- Q5: Churn by geography (with share of all churners)
SELECT geography, COUNT(*) AS customers, SUM(churned) AS churned,
       ROUND(100.0 * SUM(churned) / COUNT(*), 1) AS churn_rate_pct,
       ROUND(100.0 * SUM(churned) / (SELECT SUM(churned) FROM customers), 1) AS share_of_all_churners_pct
FROM customers GROUP BY geography ORDER BY churn_rate_pct DESC;

-- Q6: Geography x activity (is Germany just an activity problem?)
SELECT geography, CASE WHEN is_active = 1 THEN 'Active' ELSE 'Inactive' END AS activity_status,
       COUNT(*) AS customers, ROUND(100.0 * SUM(churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers GROUP BY geography, activity_status ORDER BY geography, activity_status;

-- Q7: Gender and balance checks
SELECT 'gender: ' || gender AS segment, COUNT(*) AS customers,
       ROUND(100.0 * SUM(churned) / COUNT(*), 1) AS churn_rate_pct
FROM customers GROUP BY gender
UNION ALL
SELECT CASE WHEN balance = 0 THEN 'balance: zero' ELSE 'balance: positive' END, COUNT(*),
       ROUND(100.0 * SUM(churned) / COUNT(*), 1)
FROM customers GROUP BY CASE WHEN balance = 0 THEN 'balance: zero' ELSE 'balance: positive' END;

-- Q8: Risk tiers (simple, explainable rules a retention team can audit)
-- High  : 3+ products, OR age 45-64 and (inactive OR in Germany)
-- Medium: age 40+, OR Germany, OR single-product inactive
-- Low   : everyone else
-- Reports coverage: what share of all churners each tier captures.
WITH tiered AS (
    SELECT *, CASE
        WHEN num_products >= 3 OR (age >= 45 AND age < 65 AND (is_active = 0 OR geography = 'Germany')) THEN 'High'
        WHEN age >= 40 OR geography = 'Germany' OR (num_products = 1 AND is_active = 0) THEN 'Medium'
        ELSE 'Low' END AS churn_risk_tier
    FROM customers
)
SELECT churn_risk_tier, COUNT(*) AS customers,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM customers), 1) AS share_of_customers_pct,
       SUM(churned) AS churned,
       ROUND(100.0 * SUM(churned) / COUNT(*), 1) AS actual_churn_rate_pct,
       ROUND(100.0 * SUM(churned) / (SELECT SUM(churned) FROM customers), 1) AS share_of_all_churners_pct,
       ROUND(AVG(balance), 0) AS avg_balance
FROM tiered GROUP BY churn_risk_tier
ORDER BY actual_churn_rate_pct DESC;
