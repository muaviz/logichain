-- ============================================================================
-- 1. UPDATABLE VIEWS & DATA INDEPENDENCE
-- Maps to CSE3001 Unit 3 (Creating Views, Data Independence, Security, Updates on Views)
-- ============================================================================

-- View 1: Active Product Catalog (Restricted to non-discontinued items)
DROP VIEW IF EXISTS VW_ACTIVE_PRODUCTS;
CREATE VIEW VW_ACTIVE_PRODUCTS AS
SELECT 
    product_id,
    sku,
    product_name,
    category_id,
    material_type,
    unit_weight_kg,
    base_price,
    reorder_threshold
FROM PRODUCT
WHERE is_discontinued = 0;

-- View 2: High Priority / Active Customers View
DROP VIEW IF EXISTS VW_ACTIVE_CUSTOMERS;
CREATE VIEW VW_ACTIVE_CUSTOMERS AS
SELECT 
    customer_id,
    customer_code,
    company_name,
    contact_name,
    contact_email,
    credit_limit,
    balance_due
FROM CUSTOMER
WHERE status = 'ACTIVE' AND credit_limit >= 20000.00;

-- View 3: Operational Fleet Overview (Excludes decommissioned vehicles)
DROP VIEW IF EXISTS VW_OPERATIONAL_FLEET;
CREATE VIEW VW_OPERATIONAL_FLEET AS
SELECT 
    vehicle_id,
    license_plate,
    type_code,
    current_warehouse_id,
    status,
    total_km_driven
FROM VEHICLE
WHERE status IN ('AVAILABLE', 'IN_TRANSIT', 'MAINTENANCE');
