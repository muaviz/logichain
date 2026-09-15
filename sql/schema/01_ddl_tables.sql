-- ============================================================================
-- LOGICHAIN ENTERPRISE SUPPLY CHAIN & LOGISTICS SYSTEM
-- Master DDL Schema Definition
-- Maps to CSE3001 Unit 1, Unit 2, Unit 3 (DDL, Integrity Constraints, ER Mapping)
-- ============================================================================

-- Drop tables in reverse dependency order
DROP TABLE IF EXISTS AUDIT_INVENTORY_LOG;
DROP TABLE IF EXISTS AUDIT_CLIENT_LOG;
DROP TABLE IF EXISTS SHIPMENT_ITEM;
DROP TABLE IF EXISTS SHIPMENT;
DROP TABLE IF EXISTS ORDER_ITEM;
DROP TABLE IF EXISTS CUSTOMER_ORDER;
DROP TABLE IF EXISTS INVENTORY_STOCK;
DROP TABLE IF EXISTS WAREHOUSE_BIN;
DROP TABLE IF EXISTS DRIVER_CERTIFICATION;
DROP TABLE IF EXISTS VEHICLE;
DROP TABLE IF EXISTS VEHICLE_TYPE;
DROP TABLE IF EXISTS EMPLOYEE_DEPENDENT;
DROP TABLE IF EXISTS SUPPLIER_PRODUCT;
DROP TABLE IF EXISTS PRODUCT;
DROP TABLE IF EXISTS PRODUCT_CATEGORY;
DROP TABLE IF EXISTS WAREHOUSE;
DROP TABLE IF EXISTS CUSTOMER;
DROP TABLE IF EXISTS SUPPLIER;
DROP TABLE IF EXISTS EMPLOYEE;
DROP TABLE IF EXISTS GEOGRAPHY_LOCATION;

-- ----------------------------------------------------------------------------
-- 1. GEOGRAPHY_LOCATION (Spatial Hierarchy - 3NF Decomposed)
-- ----------------------------------------------------------------------------
CREATE TABLE GEOGRAPHY_LOCATION (
    loc_id INTEGER PRIMARY KEY,
    city VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL DEFAULT 'USA',
    postal_code VARCHAR(20) NOT NULL,
    latitude DECIMAL(9, 6),
    longitude DECIMAL(9, 6),
    CONSTRAINT chk_postal_not_empty CHECK (LENGTH(postal_code) >= 3)
);

-- ----------------------------------------------------------------------------
-- 2. EMPLOYEE (Self-Referencing Boss/Manager Hierarchy - Lab 11)
-- ----------------------------------------------------------------------------
CREATE TABLE EMPLOYEE (
    emp_id INTEGER PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    hire_date DATE NOT NULL,
    job_role VARCHAR(50) NOT NULL,
    department_name VARCHAR(50) NOT NULL,
    salary DECIMAL(12, 2) NOT NULL,
    commission_pct DECIMAL(4, 2) DEFAULT 0.00,
    manager_id INTEGER,
    is_active INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT chk_emp_salary CHECK (salary > 0),
    CONSTRAINT chk_emp_commission CHECK (commission_pct >= 0.00 AND commission_pct <= 1.00),
    CONSTRAINT fk_emp_manager FOREIGN KEY (manager_id) 
        REFERENCES EMPLOYEE(emp_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 3. EMPLOYEE_DEPENDENT (Weak Entity Set - Identifying Owner: EMPLOYEE)
-- ----------------------------------------------------------------------------
CREATE TABLE EMPLOYEE_DEPENDENT (
    emp_id INTEGER NOT NULL,
    dependent_name VARCHAR(100) NOT NULL,
    relationship VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    gender VARCHAR(10),
    PRIMARY KEY (emp_id, dependent_name),
    CONSTRAINT fk_dependent_emp FOREIGN KEY (emp_id) 
        REFERENCES EMPLOYEE(emp_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 4. SUPPLIER (Vendors & Manufacturers)
-- ----------------------------------------------------------------------------
CREATE TABLE SUPPLIER (
    supplier_id INTEGER PRIMARY KEY,
    company_name VARCHAR(120) NOT NULL UNIQUE,
    contact_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(25) NOT NULL,
    loc_id INTEGER NOT NULL,
    tax_id VARCHAR(50) NOT NULL UNIQUE,
    rating INTEGER NOT NULL DEFAULT 3,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_supplier_rating CHECK (rating >= 1 AND rating <= 5),
    CONSTRAINT fk_supplier_loc FOREIGN KEY (loc_id) 
        REFERENCES GEOGRAPHY_LOCATION(loc_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 5. PRODUCT_CATEGORY (Hierarchical Taxonomy)
-- ----------------------------------------------------------------------------
CREATE TABLE PRODUCT_CATEGORY (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL UNIQUE,
    department VARCHAR(50) NOT NULL,
    parent_category_id INTEGER,
    CONSTRAINT fk_category_parent FOREIGN KEY (parent_category_id) 
        REFERENCES PRODUCT_CATEGORY(category_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 6. PRODUCT (Parts & Finished Goods)
-- ----------------------------------------------------------------------------
CREATE TABLE PRODUCT (
    product_id INTEGER PRIMARY KEY,
    sku VARCHAR(50) NOT NULL UNIQUE,
    product_name VARCHAR(150) NOT NULL,
    category_id INTEGER NOT NULL,
    material_type VARCHAR(50) NOT NULL,
    unit_weight_kg DECIMAL(8, 2) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL,
    reorder_threshold INTEGER NOT NULL DEFAULT 10,
    is_discontinued INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT chk_prod_price CHECK (base_price >= 0.0),
    CONSTRAINT chk_prod_weight CHECK (unit_weight_kg > 0.0),
    CONSTRAINT fk_prod_category FOREIGN KEY (category_id) 
        REFERENCES PRODUCT_CATEGORY(category_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 7. SUPPLIER_PRODUCT (M:N Associative Entity - Supplier Parts Catalog)
-- ----------------------------------------------------------------------------
CREATE TABLE SUPPLIER_PRODUCT (
    supplier_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    supply_price DECIMAL(10, 2) NOT NULL,
    lead_time_days INTEGER NOT NULL DEFAULT 3,
    minimum_order_qty INTEGER NOT NULL DEFAULT 1,
    PRIMARY KEY (supplier_id, product_id),
    CONSTRAINT chk_supply_price CHECK (supply_price >= 0.0),
    CONSTRAINT fk_sp_supplier FOREIGN KEY (supplier_id) 
        REFERENCES SUPPLIER(supplier_id) ON DELETE CASCADE,
    CONSTRAINT fk_sp_product FOREIGN KEY (product_id) 
        REFERENCES PRODUCT(product_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 8. WAREHOUSE (Fulfillment Hubs & Storage Centers)
-- ----------------------------------------------------------------------------
CREATE TABLE WAREHOUSE (
    warehouse_id INTEGER PRIMARY KEY,
    warehouse_code VARCHAR(20) NOT NULL UNIQUE,
    warehouse_name VARCHAR(100) NOT NULL,
    loc_id INTEGER NOT NULL,
    manager_id INTEGER,
    total_capacity_sqft INTEGER NOT NULL,
    is_operational INTEGER NOT NULL DEFAULT 1,
    CONSTRAINT chk_wh_capacity CHECK (total_capacity_sqft > 0),
    CONSTRAINT fk_wh_loc FOREIGN KEY (loc_id) 
        REFERENCES GEOGRAPHY_LOCATION(loc_id) ON DELETE RESTRICT,
    CONSTRAINT fk_wh_manager FOREIGN KEY (manager_id) 
        REFERENCES EMPLOYEE(emp_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 9. WAREHOUSE_BIN (Weak Entity Set - Identifying Owner: WAREHOUSE)
-- ----------------------------------------------------------------------------
CREATE TABLE WAREHOUSE_BIN (
    warehouse_id INTEGER NOT NULL,
    bin_code VARCHAR(20) NOT NULL,
    aisle VARCHAR(10) NOT NULL,
    rack VARCHAR(10) NOT NULL,
    shelf_level INTEGER NOT NULL,
    zone_type VARCHAR(30) NOT NULL DEFAULT 'STANDARD',
    max_volume_cbm DECIMAL(6, 2) NOT NULL DEFAULT 5.0,
    PRIMARY KEY (warehouse_id, bin_code),
    CONSTRAINT fk_bin_warehouse FOREIGN KEY (warehouse_id) 
        REFERENCES WAREHOUSE(warehouse_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 10. INVENTORY_STOCK (Stock per Bin/Warehouse)
-- ----------------------------------------------------------------------------
CREATE TABLE INVENTORY_STOCK (
    stock_id INTEGER PRIMARY KEY,
    warehouse_id INTEGER NOT NULL,
    bin_code VARCHAR(20) NOT NULL,
    product_id INTEGER NOT NULL,
    quantity_on_hand INTEGER NOT NULL DEFAULT 0,
    quantity_reserved INTEGER NOT NULL DEFAULT 0,
    last_restock_date DATE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_qty_on_hand CHECK (quantity_on_hand >= 0),
    CONSTRAINT chk_qty_reserved CHECK (quantity_reserved >= 0 AND quantity_reserved <= quantity_on_hand),
    CONSTRAINT fk_stock_bin FOREIGN KEY (warehouse_id, bin_code) 
        REFERENCES WAREHOUSE_BIN(warehouse_id, bin_code) ON DELETE CASCADE,
    CONSTRAINT fk_stock_product FOREIGN KEY (product_id) 
        REFERENCES PRODUCT(product_id) ON DELETE RESTRICT,
    CONSTRAINT uq_wh_bin_product UNIQUE (warehouse_id, bin_code, product_id)
);

-- ----------------------------------------------------------------------------
-- 11. VEHICLE_TYPE (Fleet Categorization & Specifications)
-- ----------------------------------------------------------------------------
CREATE TABLE VEHICLE_TYPE (
    type_code VARCHAR(20) PRIMARY KEY,
    type_name VARCHAR(50) NOT NULL,
    max_payload_kg DECIMAL(10, 2) NOT NULL,
    cruising_range_km INTEGER NOT NULL,
    requires_special_license INTEGER NOT NULL DEFAULT 0,
    CONSTRAINT chk_payload CHECK (max_payload_kg > 0),
    CONSTRAINT chk_range CHECK (cruising_range_km > 0)
);

-- ----------------------------------------------------------------------------
-- 12. VEHICLE (Fleet Assets)
-- ----------------------------------------------------------------------------
CREATE TABLE VEHICLE (
    vehicle_id INTEGER PRIMARY KEY,
    vin VARCHAR(30) NOT NULL UNIQUE,
    license_plate VARCHAR(20) NOT NULL UNIQUE,
    type_code VARCHAR(20) NOT NULL,
    current_warehouse_id INTEGER NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'AVAILABLE',
    total_km_driven INTEGER NOT NULL DEFAULT 0,
    last_maintenance_date DATE,
    CONSTRAINT chk_vehicle_status CHECK (status IN ('AVAILABLE', 'IN_TRANSIT', 'MAINTENANCE', 'DECOMMISSIONED')),
    CONSTRAINT fk_veh_type FOREIGN KEY (type_code) 
        REFERENCES VEHICLE_TYPE(type_code) ON DELETE RESTRICT,
    CONSTRAINT fk_veh_wh FOREIGN KEY (current_warehouse_id) 
        REFERENCES WAREHOUSE(warehouse_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 13. DRIVER_CERTIFICATION (Pilot/Driver Certification Mapping - Lab 1)
-- ----------------------------------------------------------------------------
CREATE TABLE DRIVER_CERTIFICATION (
    emp_id INTEGER NOT NULL,
    type_code VARCHAR(20) NOT NULL,
    certification_number VARCHAR(50) NOT NULL UNIQUE,
    issue_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    PRIMARY KEY (emp_id, type_code),
    CONSTRAINT chk_cert_dates CHECK (expiry_date > issue_date),
    CONSTRAINT fk_cert_emp FOREIGN KEY (emp_id) 
        REFERENCES EMPLOYEE(emp_id) ON DELETE CASCADE,
    CONSTRAINT fk_cert_type FOREIGN KEY (type_code) 
        REFERENCES VEHICLE_TYPE(type_code) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 14. CUSTOMER (Client Master - Lab 5)
-- ----------------------------------------------------------------------------
CREATE TABLE CUSTOMER (
    customer_id INTEGER PRIMARY KEY,
    customer_code VARCHAR(30) NOT NULL UNIQUE,
    company_name VARCHAR(120) NOT NULL,
    contact_name VARCHAR(100) NOT NULL,
    contact_email VARCHAR(100) NOT NULL,
    contact_phone VARCHAR(25) NOT NULL,
    loc_id INTEGER NOT NULL,
    credit_limit DECIMAL(12, 2) NOT NULL DEFAULT 10000.00,
    balance_due DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_customer_credit CHECK (credit_limit >= 0.0),
    CONSTRAINT chk_customer_balance CHECK (balance_due >= 0.0),
    CONSTRAINT fk_customer_loc FOREIGN KEY (loc_id) 
        REFERENCES GEOGRAPHY_LOCATION(loc_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 15. CUSTOMER_ORDER (Sales Orders)
-- ----------------------------------------------------------------------------
CREATE TABLE CUSTOMER_ORDER (
    order_id INTEGER PRIMARY KEY,
    order_number VARCHAR(40) NOT NULL UNIQUE,
    customer_id INTEGER NOT NULL,
    order_date DATE NOT NULL,
    required_date DATE NOT NULL,
    shipped_date DATE,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING',
    subtotal DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    discount_pct DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
    tax_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    total_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_order_status CHECK (status IN ('PENDING', 'PROCESSING', 'SHIPPED', 'DELIVERED', 'CANCELLED')),
    CONSTRAINT chk_order_dates CHECK (required_date >= order_date),
    CONSTRAINT fk_order_customer FOREIGN KEY (customer_id) 
        REFERENCES CUSTOMER(customer_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 16. ORDER_ITEM (Order Line Items)
-- ----------------------------------------------------------------------------
CREATE TABLE ORDER_ITEM (
    order_id INTEGER NOT NULL,
    item_seq INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    ordered_qty INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    discount_rate DECIMAL(4, 2) NOT NULL DEFAULT 0.00,
    line_total DECIMAL(12, 2) NOT NULL,
    PRIMARY KEY (order_id, item_seq),
    CONSTRAINT chk_ordered_qty CHECK (ordered_qty > 0),
    CONSTRAINT chk_unit_price CHECK (unit_price >= 0.0),
    CONSTRAINT fk_item_order FOREIGN KEY (order_id) 
        REFERENCES CUSTOMER_ORDER(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_item_product FOREIGN KEY (product_id) 
        REFERENCES PRODUCT(product_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 17. SHIPMENT (Cargo Manifest & Dispatch)
-- ----------------------------------------------------------------------------
CREATE TABLE SHIPMENT (
    shipment_id INTEGER PRIMARY KEY,
    shipment_code VARCHAR(40) NOT NULL UNIQUE,
    order_id INTEGER NOT NULL,
    origin_warehouse_id INTEGER NOT NULL,
    vehicle_id INTEGER NOT NULL,
    driver_id INTEGER NOT NULL,
    inspector_id INTEGER,
    dispatch_date TIMESTAMP,
    delivery_date TIMESTAMP,
    status VARCHAR(30) NOT NULL DEFAULT 'SCHEDULED',
    freight_cost DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    CONSTRAINT chk_shipment_status CHECK (status IN ('SCHEDULED', 'LOADING', 'IN_TRANSIT', 'DELIVERED', 'FAILED')),
    CONSTRAINT chk_freight_cost CHECK (freight_cost >= 0.0),
    CONSTRAINT fk_ship_order FOREIGN KEY (order_id) 
        REFERENCES CUSTOMER_ORDER(order_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ship_wh FOREIGN KEY (origin_warehouse_id) 
        REFERENCES WAREHOUSE(warehouse_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ship_vehicle FOREIGN KEY (vehicle_id) 
        REFERENCES VEHICLE(vehicle_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ship_driver FOREIGN KEY (driver_id) 
        REFERENCES EMPLOYEE(emp_id) ON DELETE RESTRICT,
    CONSTRAINT fk_ship_inspector FOREIGN KEY (inspector_id) 
        REFERENCES EMPLOYEE(emp_id) ON DELETE SET NULL
);

-- ----------------------------------------------------------------------------
-- 18. SHIPMENT_ITEM (Weak Entity Set - Identifying Owner: SHIPMENT)
-- ----------------------------------------------------------------------------
CREATE TABLE SHIPMENT_ITEM (
    shipment_id INTEGER NOT NULL,
    item_seq INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity_shipped INTEGER NOT NULL,
    unit_price DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (shipment_id, item_seq),
    CONSTRAINT chk_ship_qty CHECK (quantity_shipped > 0),
    CONSTRAINT fk_sitem_shipment FOREIGN KEY (shipment_id) 
        REFERENCES SHIPMENT(shipment_id) ON DELETE CASCADE,
    CONSTRAINT fk_sitem_product FOREIGN KEY (product_id) 
        REFERENCES PRODUCT(product_id) ON DELETE RESTRICT
);

-- ----------------------------------------------------------------------------
-- 19. AUDIT_CLIENT_LOG (Transparent Customer Audit - Lab 5)
-- ----------------------------------------------------------------------------
CREATE TABLE AUDIT_CLIENT_LOG (
    audit_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    company_name VARCHAR(120),
    old_balance_due DECIMAL(12, 2),
    new_balance_due DECIMAL(12, 2),
    operation VARCHAR(20) NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    db_user VARCHAR(50) NOT NULL DEFAULT 'SYSTEM_USER',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 20. AUDIT_INVENTORY_LOG (Stock Movement Audit)
-- ----------------------------------------------------------------------------
CREATE TABLE AUDIT_INVENTORY_LOG (
    audit_id INTEGER PRIMARY KEY,
    stock_id INTEGER NOT NULL,
    warehouse_id INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    old_qty_on_hand INTEGER,
    new_qty_on_hand INTEGER,
    operation VARCHAR(20) NOT NULL,
    db_user VARCHAR(50) NOT NULL DEFAULT 'SYSTEM_USER',
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
