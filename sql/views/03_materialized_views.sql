-- ============================================================================
-- 3. ANALYTICAL MATERIALIZED & AGGREGATE SUMMARY VIEWS
-- Maps to CSE3001 Unit 3 (Views, Comparison between Tables and Views, Reporting)
-- ============================================================================

-- Analytical View 1: Supplier Reliability & Performance Scorecard
DROP VIEW IF EXISTS VW_SUPPLIER_PERFORMANCE_METRICS;
CREATE VIEW VW_SUPPLIER_PERFORMANCE_METRICS AS
SELECT 
    s.supplier_id,
    s.company_name,
    g.city AS supplier_city,
    g.state AS supplier_state,
    s.rating AS supplier_star_rating,
    COUNT(sp.product_id) AS catalog_part_count,
    ROUND(AVG(sp.supply_price), 2) AS avg_supply_price,
    ROUND(AVG(sp.lead_time_days), 1) AS avg_lead_time_days,
    MIN(sp.supply_price) AS min_item_price,
    MAX(sp.supply_price) AS max_item_price
FROM SUPPLIER s
JOIN GEOGRAPHY_LOCATION g ON s.loc_id = g.loc_id
LEFT JOIN SUPPLIER_PRODUCT sp ON s.supplier_id = sp.supplier_id
GROUP BY s.supplier_id, s.company_name, g.city, g.state, s.rating;

-- Analytical View 2: High-Value Customer Receivables Summary
DROP VIEW IF EXISTS VW_CUSTOMER_AGING_RECEIVABLES;
CREATE VIEW VW_CUSTOMER_AGING_RECEIVABLES AS
SELECT 
    c.customer_id,
    c.company_name,
    c.credit_limit,
    c.balance_due,
    ROUND((c.balance_due / NULLIF(c.credit_limit, 0)) * 100.0, 2) AS credit_utilization_pct,
    COUNT(o.order_id) AS total_orders_placed,
    COALESCE(SUM(o.total_amount), 0.00) AS total_lifetime_order_value
FROM CUSTOMER c
LEFT JOIN CUSTOMER_ORDER o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.company_name, c.credit_limit, c.balance_due;
