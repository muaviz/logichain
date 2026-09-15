-- ============================================================================
-- 2. SECURITY & ROLE-BASED ACCESS ABSTRACTION VIEWS
-- Maps to CSE3001 Unit 1 & Unit 3 (External Level of ANSI-SPARC, Views & Security)
-- ============================================================================

-- Security View 1: Public Driver Directory (Hides sensitive base salaries & commission)
DROP VIEW IF EXISTS VW_DRIVER_PUBLIC_PROFILE;
CREATE VIEW VW_DRIVER_PUBLIC_PROFILE AS
SELECT 
    e.emp_id AS driver_id,
    e.first_name || ' ' || e.last_name AS full_name,
    e.job_role,
    e.department_name,
    e.hire_date,
    vt.type_name AS certified_vehicle_type,
    dc.certification_number,
    dc.expiry_date AS cert_expiry
FROM EMPLOYEE e
JOIN DRIVER_CERTIFICATION dc ON e.emp_id = dc.emp_id
JOIN VEHICLE_TYPE vt ON dc.type_code = vt.type_code
WHERE e.job_role LIKE '%Driver%';

-- Security View 2: Warehouse Inventory Dashboard (Aggregates without exposing cost margins)
DROP VIEW IF EXISTS VW_WAREHOUSE_INVENTORY_METRICS;
CREATE VIEW VW_WAREHOUSE_INVENTORY_METRICS AS
SELECT 
    w.warehouse_id,
    w.warehouse_code,
    w.warehouse_name,
    g.city,
    g.state,
    COUNT(DISTINCT s.product_id) AS total_distinct_skus,
    SUM(s.quantity_on_hand) AS total_units_in_stock,
    SUM(s.quantity_reserved) AS total_units_reserved,
    SUM(s.quantity_on_hand - s.quantity_reserved) AS total_available_units
FROM WAREHOUSE w
JOIN GEOGRAPHY_LOCATION g ON w.loc_id = g.loc_id
LEFT JOIN INVENTORY_STOCK s ON w.warehouse_id = s.warehouse_id
GROUP BY w.warehouse_id, w.warehouse_code, w.warehouse_name, g.city, g.state;

-- Security View 3: Customer Invoice & Order Summary
DROP VIEW IF EXISTS VW_CUSTOMER_ORDER_BILLING;
CREATE VIEW VW_CUSTOMER_ORDER_BILLING AS
SELECT 
    c.customer_id,
    c.customer_code,
    c.company_name,
    o.order_id,
    o.order_number,
    o.order_date,
    o.status AS order_status,
    o.total_amount,
    COALESCE(s.status, 'UNASSIGNED') AS shipment_status,
    s.dispatch_date,
    s.delivery_date
FROM CUSTOMER c
JOIN CUSTOMER_ORDER o ON c.customer_id = o.customer_id
LEFT JOIN SHIPMENT s ON o.order_id = s.order_id;
