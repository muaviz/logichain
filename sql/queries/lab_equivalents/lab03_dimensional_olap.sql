-- ============================================================================
-- LAB 3 EQUIVALENT: WHOLESALE INVENTORY & PRODUCT SALES ANALYSIS
-- Maps to CSE3001 Lab 3 (Wholesale Furniture / Product / Spatial / Time Analytics)
-- Evaluated directly on the normalized relational schema (No Star Schema needed)
-- ============================================================================

-- Query 1: Sales Analysis by Product Material Type (Wood, Marble, Steel, Polymer)
-- Analyzes Quantity, Gross Sales, Discount, and Net Realized Revenue
SELECT 
    p.material_type,
    COUNT(oi.order_id) AS total_order_items,
    SUM(oi.ordered_qty) AS total_units_sold,
    ROUND(SUM(oi.ordered_qty * oi.unit_price), 2) AS gross_income,
    ROUND(SUM(oi.ordered_qty * oi.unit_price * oi.discount_rate), 2) AS total_discounts,
    ROUND(SUM(oi.line_total), 2) AS net_realized_income,
    ROUND(AVG(oi.line_total), 2) AS avg_item_sale_amount
FROM ORDER_ITEM oi
JOIN PRODUCT p ON oi.product_id = p.product_id
GROUP BY p.material_type
ORDER BY net_realized_income DESC;

-- Query 2: Spatial Hierarchy Sales Analysis (State -> Region -> City)
SELECT 
    g.state,
    g.region,
    g.city,
    COUNT(o.order_id) AS total_orders,
    ROUND(SUM(o.total_amount), 2) AS regional_net_income,
    ROUND(AVG(o.discount_pct * 100), 2) AS avg_discount_rate_pct
FROM CUSTOMER_ORDER o
JOIN CUSTOMER c ON o.customer_id = c.customer_id
JOIN GEOGRAPHY_LOCATION g ON c.loc_id = g.loc_id
GROUP BY g.state, g.region, g.city
ORDER BY g.state, regional_net_income DESC;

-- Query 3: Multi-Dimensional Cross-Tabulation: Product Category vs Geographic Region
SELECT 
    pc.category_name,
    g.region,
    SUM(oi.ordered_qty) AS units_sold,
    ROUND(SUM(oi.line_total), 2) AS total_revenue
FROM ORDER_ITEM oi
JOIN PRODUCT p ON oi.product_id = p.product_id
JOIN PRODUCT_CATEGORY pc ON p.category_id = pc.category_id
JOIN CUSTOMER_ORDER o ON oi.order_id = o.order_id
JOIN CUSTOMER c ON o.customer_id = c.customer_id
JOIN GEOGRAPHY_LOCATION g ON c.loc_id = g.loc_id
GROUP BY pc.category_name, g.region
ORDER BY pc.category_name, total_revenue DESC;

-- Query 4: Dispatch Lead-Time and Shipment Analysis per Warehouse
SELECT 
    w.warehouse_code,
    w.warehouse_name,
    COUNT(s.shipment_id) AS shipments_count,
    ROUND(AVG(s.freight_cost), 2) AS avg_freight_cost,
    ROUND(SUM(s.freight_cost), 2) AS total_freight_cost
FROM SHIPMENT s
JOIN WAREHOUSE w ON s.origin_warehouse_id = w.warehouse_id
GROUP BY w.warehouse_code, w.warehouse_name
ORDER BY shipments_count DESC;
