-- ============================================================================
-- LAB 3 EQUIVALENT: WHOLESALE MULTI-DIMENSIONAL OLAP ANALYSIS
-- Maps to CSE3001 Lab 3 (Wholesale Furniture / Product / Spatial / Time Analytics)
-- ============================================================================

-- Query 1: Sales Analysis by Product Material Type (Wood, Marble, Steel, Polymer)
-- Analyzes Quantity, Gross Revenue, Discount, Net Revenue, and Profit Margin
SELECT 
    dp.material_type,
    COUNT(f.fact_sales_id) AS total_transactions,
    SUM(f.quantity_sold) AS total_units_sold,
    SUM(f.gross_revenue) AS total_gross_income,
    SUM(f.discount_amount) AS total_discounts_granted,
    SUM(f.net_revenue) AS net_realized_income,
    ROUND(AVG(f.profit_margin), 2) AS avg_profit_margin
FROM FACT_SALES_SHIPMENT f
JOIN DIM_PRODUCT_HIERARCHY dp ON f.dim_product_key = dp.dim_product_key
GROUP BY dp.material_type
ORDER BY net_realized_income DESC;

-- Query 2: Spatial Hierarchy Sales Analysis (State -> Region -> City)
SELECT 
    dl.state,
    dl.region,
    dl.city,
    SUM(f.quantity_sold) AS total_quantity,
    SUM(f.net_revenue) AS regional_net_income,
    ROUND(SUM(f.discount_amount) / NULLIF(SUM(f.gross_revenue), 0) * 100.0, 2) AS avg_discount_rate_pct
FROM FACT_SALES_SHIPMENT f
JOIN DIM_CUSTOMER_LOCATION dl ON f.dim_location_key = dl.dim_location_key
GROUP BY dl.state, dl.region, dl.city
ORDER BY dl.state, regional_net_income DESC;

-- Query 3: Multi-Dimensional Cross-Tabulation: Product Category vs Geographic Region
SELECT 
    dp.category_name,
    dl.region,
    SUM(f.quantity_sold) AS units_sold,
    SUM(f.net_revenue) AS total_revenue
FROM FACT_SALES_SHIPMENT f
JOIN DIM_PRODUCT_HIERARCHY dp ON f.dim_product_key = dp.dim_product_key
JOIN DIM_CUSTOMER_LOCATION dl ON f.dim_location_key = dl.dim_location_key
GROUP BY dp.category_name, dl.region
ORDER BY dp.category_name, total_revenue DESC;

-- Query 4: Temporal Trend & Warehouse Fulfillment Lead-Time Analysis
SELECT 
    dt.calendar_year,
    dt.calendar_quarter,
    dt.month_name,
    dw.warehouse_name,
    SUM(f.net_revenue) AS monthly_revenue,
    ROUND(AVG(f.delivery_lead_time_days), 1) AS avg_delivery_days,
    SUM(f.freight_cost_share) AS total_freight_incurred
FROM FACT_SALES_SHIPMENT f
JOIN DIM_TIME dt ON f.dim_time_key = dt.dim_time_key
JOIN DIM_WAREHOUSE_HUB dw ON f.dim_warehouse_key = dw.dim_warehouse_key
GROUP BY dt.calendar_year, dt.calendar_quarter, dt.month_name, dw.warehouse_name
ORDER BY dt.calendar_year, dt.month_number;
