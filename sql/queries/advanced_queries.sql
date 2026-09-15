-- ============================================================================
-- ADVANCED SQL QUERIES & RELATIONAL SUBQUERIES
-- Maps to CSE3001 Unit 3 (Nested Subqueries, Correlated EXISTS, Aggregations, Joins)
-- ============================================================================

-- 1. Correlated Subquery with EXISTS: Suppliers who supply at least one product with zero warehouse inventory
SELECT s.supplier_id, s.company_name, s.contact_phone
FROM SUPPLIER s
WHERE EXISTS (
    SELECT 1
    FROM SUPPLIER_PRODUCT sp
    WHERE sp.supplier_id = s.supplier_id
      AND NOT EXISTS (
          SELECT 1
          FROM INVENTORY_STOCK inv
          WHERE inv.product_id = sp.product_id AND inv.quantity_on_hand > 0
      )
);

-- 2. Scalar Nested Subquery: Orders with total amount greater than average order value
SELECT 
    o.order_id,
    o.order_number,
    c.company_name,
    o.total_amount,
    ROUND((SELECT AVG(total_amount) FROM CUSTOMER_ORDER), 2) AS overall_avg_order_value,
    ROUND(o.total_amount - (SELECT AVG(total_amount) FROM CUSTOMER_ORDER), 2) AS diff_from_avg
FROM CUSTOMER_ORDER o
JOIN CUSTOMER c ON o.customer_id = c.customer_id
WHERE o.total_amount > (SELECT AVG(total_amount) FROM CUSTOMER_ORDER)
ORDER BY o.total_amount DESC;

-- 3. Multi-Table Join with Aggregation & HAVING: Total sales value fulfilled per origin warehouse
SELECT 
    w.warehouse_id,
    w.warehouse_name,
    g.city AS warehouse_city,
    COUNT(s.shipment_id) AS total_shipments_dispatched,
    COALESCE(SUM(o.total_amount), 0.00) AS total_order_value_fulfilled,
    COALESCE(SUM(s.freight_cost), 0.00) AS total_freight_incurred
FROM WAREHOUSE w
JOIN GEOGRAPHY_LOCATION g ON w.loc_id = g.loc_id
LEFT JOIN SHIPMENT s ON w.warehouse_id = s.origin_warehouse_id
LEFT JOIN CUSTOMER_ORDER o ON s.order_id = o.order_id
GROUP BY w.warehouse_id, w.warehouse_name, g.city
HAVING COUNT(s.shipment_id) >= 1
ORDER BY total_order_value_fulfilled DESC;

-- 4. Window Functions / Ranking: Rank products by sales revenue within their category
SELECT 
    p.category_id,
    p.product_name,
    p.base_price,
    COALESCE(SUM(oi.ordered_qty), 0) AS units_sold,
    COALESCE(SUM(oi.line_total), 0.00) AS revenue_generated,
    RANK() OVER (PARTITION BY p.category_id ORDER BY COALESCE(SUM(oi.line_total), 0.00) DESC) AS revenue_rank_in_category
FROM PRODUCT p
LEFT JOIN ORDER_ITEM oi ON p.product_id = oi.product_id
GROUP BY p.category_id, p.product_id, p.product_name, p.base_price;
