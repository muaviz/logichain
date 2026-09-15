-- ============================================================================
-- PERFORMANCE INDEXING SUITE
-- Maps to CSE3001 Unit 4 (Ordered Indices, B+ Tree Indexes, Static/Dynamic Hashing)
-- ============================================================================

-- 1. Composite B-Tree Index on Orders for Customer Lookup & Date Range Range Scans
DROP INDEX IF EXISTS idx_orders_customer_date;
CREATE INDEX idx_orders_customer_date 
ON CUSTOMER_ORDER (customer_id, order_date DESC);

-- 2. Composite B-Tree Index on Inventory for Fast Warehouse-Product Lookups
DROP INDEX IF EXISTS idx_inventory_wh_prod;
CREATE INDEX idx_inventory_wh_prod 
ON INVENTORY_STOCK (warehouse_id, product_id);

-- 3. Composite B-Tree Index on Shipments for Driver & Status Tracking
DROP INDEX IF EXISTS idx_shipment_driver_status;
CREATE INDEX idx_shipment_driver_status 
ON SHIPMENT (driver_id, status);

-- 4. B-Tree Index on Employee Manager Hierarchy (Optimizes Self-Join Traversal)
DROP INDEX IF EXISTS idx_emp_manager;
CREATE INDEX idx_emp_manager 
ON EMPLOYEE (manager_id);

-- 5. B-Tree Index on Product SKU (Optimizes Exact Point-Lookups)
DROP INDEX IF EXISTS idx_product_sku;
CREATE INDEX idx_product_sku 
ON PRODUCT (sku);

-- 6. Covering Index on Supplier Products for Rapid Pricing Queries
DROP INDEX IF EXISTS idx_supp_prod_pricing;
CREATE INDEX idx_supp_prod_pricing 
ON SUPPLIER_PRODUCT (product_id, supplier_id, supply_price);

-- 7. Index on Customer Balance for Credit Monitoring
DROP INDEX IF EXISTS idx_customer_balance;
CREATE INDEX idx_customer_balance 
ON CUSTOMER (balance_due);

-- 8. Spatial Index on Geography Postal Code & State
DROP INDEX IF EXISTS idx_geo_state_city;
CREATE INDEX idx_geo_state_city 
ON GEOGRAPHY_LOCATION (state, city);
