-- ============================================================================
-- LOGICHAIN DIMENSIONAL DATA WAREHOUSE SCHEMA (STAR & SNOWFLAKE MODEL)
-- Corresponds to CSE3001 Lab 3 (Wholesale Multi-dimensional Database Design)
-- Analyzes sales, revenue, discounts, and shipments across Product, Geography, Time, and Hubs
-- ============================================================================

DROP TABLE IF EXISTS FACT_SALES_SHIPMENT;
DROP TABLE IF EXISTS DIM_TIME;
DROP TABLE IF EXISTS DIM_CUSTOMER_LOCATION;
DROP TABLE IF EXISTS DIM_PRODUCT_HIERARCHY;
DROP TABLE IF EXISTS DIM_WAREHOUSE_HUB;

-- ----------------------------------------------------------------------------
-- 1. DIM_PRODUCT_HIERARCHY (Category, Subcategory, Material Dimension)
-- ----------------------------------------------------------------------------
CREATE TABLE DIM_PRODUCT_HIERARCHY (
    dim_product_key INTEGER PRIMARY KEY,
    product_id INTEGER NOT NULL,
    sku VARCHAR(50) NOT NULL,
    product_name VARCHAR(150) NOT NULL,
    category_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    material_type VARCHAR(50) NOT NULL, -- Wood, Steel, Polymer, Marble, Glass
    unit_weight_kg DECIMAL(8, 2) NOT NULL,
    base_price DECIMAL(10, 2) NOT NULL
);

-- ----------------------------------------------------------------------------
-- 2. DIM_CUSTOMER_LOCATION (Spatial Hierarchy: City, Region, State, Country)
-- ----------------------------------------------------------------------------
CREATE TABLE DIM_CUSTOMER_LOCATION (
    dim_location_key INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    customer_name VARCHAR(120) NOT NULL,
    city VARCHAR(100) NOT NULL,
    region VARCHAR(100) NOT NULL,
    state VARCHAR(100) NOT NULL,
    country VARCHAR(100) NOT NULL,
    postal_code VARCHAR(20) NOT NULL
);

-- ----------------------------------------------------------------------------
-- 3. DIM_WAREHOUSE_HUB (Origin Fulfillment Center Dimension)
-- ----------------------------------------------------------------------------
CREATE TABLE DIM_WAREHOUSE_HUB (
    dim_warehouse_key INTEGER PRIMARY KEY,
    warehouse_id INTEGER NOT NULL,
    warehouse_code VARCHAR(20) NOT NULL,
    warehouse_name VARCHAR(100) NOT NULL,
    hub_city VARCHAR(100) NOT NULL,
    hub_state VARCHAR(100) NOT NULL,
    capacity_tier VARCHAR(30) NOT NULL -- 'MEGA_HUB', 'REGIONAL_DEPOT', 'METRO_TERMINAL'
);

-- ----------------------------------------------------------------------------
-- 4. DIM_TIME (Temporal Hierarchy: Day, Month, Quarter, Year, Day of Week)
-- ----------------------------------------------------------------------------
CREATE TABLE DIM_TIME (
    dim_time_key INTEGER PRIMARY KEY, -- Format: YYYYMMDD
    full_date DATE NOT NULL UNIQUE,
    day_number_in_month INTEGER NOT NULL,
    month_number INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    calendar_quarter VARCHAR(10) NOT NULL,
    calendar_year INTEGER NOT NULL,
    day_of_week VARCHAR(20) NOT NULL,
    is_weekend INTEGER NOT NULL DEFAULT 0
);

-- ----------------------------------------------------------------------------
-- 5. FACT_SALES_SHIPMENT (Central Fact Table)
-- ----------------------------------------------------------------------------
CREATE TABLE FACT_SALES_SHIPMENT (
    fact_sales_id INTEGER PRIMARY KEY,
    dim_product_key INTEGER NOT NULL,
    dim_location_key INTEGER NOT NULL,
    dim_warehouse_key INTEGER NOT NULL,
    dim_time_key INTEGER NOT NULL,
    order_id INTEGER NOT NULL,
    shipment_id INTEGER NOT NULL,
    quantity_sold INTEGER NOT NULL,
    unit_selling_price DECIMAL(10, 2) NOT NULL,
    gross_revenue DECIMAL(12, 2) NOT NULL,
    discount_amount DECIMAL(12, 2) NOT NULL DEFAULT 0.00,
    net_revenue DECIMAL(12, 2) NOT NULL,
    freight_cost_share DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    profit_margin DECIMAL(12, 2) NOT NULL,
    delivery_lead_time_days INTEGER NOT NULL,
    CONSTRAINT fk_fact_prod FOREIGN KEY (dim_product_key) REFERENCES DIM_PRODUCT_HIERARCHY(dim_product_key),
    CONSTRAINT fk_fact_loc FOREIGN KEY (dim_location_key) REFERENCES DIM_CUSTOMER_LOCATION(dim_location_key),
    CONSTRAINT fk_fact_wh FOREIGN KEY (dim_warehouse_key) REFERENCES DIM_WAREHOUSE_HUB(dim_warehouse_key),
    CONSTRAINT fk_fact_time FOREIGN KEY (dim_time_key) REFERENCES DIM_TIME(dim_time_key)
);

-- ----------------------------------------------------------------------------
-- Seed Data for Data Warehouse Dimension Tables
-- ----------------------------------------------------------------------------
INSERT INTO DIM_PRODUCT_HIERARCHY (dim_product_key, product_id, sku, product_name, category_name, department, material_type, unit_weight_kg, base_price) VALUES
(1, 301, 'WD-OAK-001', 'Solid Oak Heavy Duty Desktop', 'Office Desks & Workstations', 'Furnishings', 'Wood', 28.50, 249.99),
(2, 302, 'WD-WAL-002', 'Walnut Executive Conference Table', 'Conference & Dining Tables', 'Furnishings', 'Wood', 85.00, 899.50),
(3, 303, 'ST-FRM-003', 'Steel Modular Desk Frame', 'Office Desks & Workstations', 'Furnishings', 'Steel', 18.20, 159.00),
(4, 304, 'CH-ERG-004', 'AeroFlex Mesh Ergonomic Task Chair', 'Ergonomic Seating', 'Furnishings', 'Polymer', 14.00, 199.99),
(5, 305, 'CH-LTH-005', 'Executive High-Back Leather Chair', 'Ergonomic Seating', 'Furnishings', 'Leather', 22.00, 349.00),
(6, 306, 'MB-TAB-006', 'Italian Carrara Marble Coffee Table', 'Conference & Dining Tables', 'Furnishings', 'Marble', 62.00, 650.00),
(7, 307, 'CB-STL-007', 'Heavy Duty 4-Drawer Steel Cabinet', 'Storage Cabinets & Racks', 'Furnishings', 'Steel', 45.00, 280.00),
(8, 308, 'CB-WOD-008', 'Nordic Pine Modular Wardrobe Unit', 'Storage Cabinets & Racks', 'Furnishings', 'Wood', 58.00, 420.00);

INSERT INTO DIM_CUSTOMER_LOCATION (dim_location_key, customer_id, customer_name, city, region, state, country, postal_code) VALUES
(1, 701, 'Metro Workspace Solutions Inc', 'New York', 'Northeast', 'NY', 'USA', '10001'),
(2, 702, 'Pacific Design Studio', 'Los Angeles', 'West', 'CA', 'USA', '90001'),
(3, 703, 'Windy City Office Supplies', 'Chicago', 'Midwest', 'IL', 'USA', '60601'),
(4, 704, 'Lone Star Corporate Interiors', 'Houston', 'South', 'TX', 'USA', '77001'),
(5, 705, 'Sound Tech Furnishings', 'Seattle', 'Northwest', 'WA', 'USA', '98101'),
(6, 706, 'Beacon Hill Commercial Interiors', 'Boston', 'Northeast', 'MA', 'USA', '02101');

INSERT INTO DIM_WAREHOUSE_HUB (dim_warehouse_key, warehouse_id, warehouse_code, warehouse_name, hub_city, hub_state, capacity_tier) VALUES
(1, 401, 'WH-NYC-01', 'LogiChain Northeast Metro Hub', 'New York', 'NY', 'MEGA_HUB'),
(2, 402, 'WH-LAX-02', 'LogiChain Pacific Gateway Depot', 'Los Angeles', 'CA', 'MEGA_HUB'),
(3, 403, 'WH-CHI-03', 'LogiChain Midwest Central Terminal', 'Chicago', 'IL', 'REGIONAL_DEPOT'),
(4, 404, 'WH-HOU-04', 'LogiChain Gulf Logistics Center', 'Houston', 'TX', 'REGIONAL_DEPOT');

INSERT INTO DIM_TIME (dim_time_key, full_date, day_number_in_month, month_number, month_name, calendar_quarter, calendar_year, day_of_week, is_weekend) VALUES
(20260801, '2026-08-01', 1, 8, 'August', 'Q3', 2026, 'Saturday', 1),
(20260803, '2026-08-03', 3, 8, 'August', 'Q3', 2026, 'Monday', 0),
(20260805, '2026-08-05', 5, 8, 'August', 'Q3', 2026, 'Wednesday', 0),
(20260807, '2026-08-07', 7, 8, 'August', 'Q3', 2026, 'Friday', 0),
(20260812, '2026-08-12', 12, 8, 'August', 'Q3', 2026, 'Wednesday', 0),
(20260814, '2026-08-14', 14, 8, 'August', 'Q3', 2026, 'Friday', 0),
(20260818, '2026-08-18', 18, 8, 'August', 'Q3', 2026, 'Tuesday', 0),
(20260820, '2026-08-20', 20, 8, 'August', 'Q3', 2026, 'Thursday', 0);

INSERT INTO FACT_SALES_SHIPMENT (fact_sales_id, dim_product_key, dim_location_key, dim_warehouse_key, dim_time_key, order_id, shipment_id, quantity_sold, unit_selling_price, gross_revenue, discount_amount, net_revenue, freight_cost_share, profit_margin, delivery_lead_time_days) VALUES
(1, 1, 1, 1, 20260803, 801, 901, 10, 249.99, 2499.90, 124.99, 2374.91, 140.00, 834.91, 2),
(2, 4, 1, 1, 20260803, 801, 901, 10, 199.99, 1999.90, 99.99, 1899.91, 100.00, 849.91, 2),
(3, 3, 1, 1, 20260803, 801, 901, 5, 159.00, 795.00, 0.00, 795.00, 40.00, 330.00, 2),
(4, 2, 2, 2, 20260807, 802, 902, 10, 899.50, 8995.00, 899.50, 8095.50, 350.00, 2545.50, 3),
(5, 5, 2, 2, 20260807, 802, 902, 3, 349.00, 1047.00, 0.00, 1047.00, 100.00, 417.00, 3),
(6, 7, 3, 1, 20260814, 803, 903, 10, 280.00, 2800.00, 0.00, 2800.00, 195.00, 1005.00, 2),
(7, 6, 4, 2, 20260820, 804, 904, 15, 650.00, 9750.00, 780.00, 8970.00, 380.00, 2890.00, 4),
(8, 8, 4, 2, 20260820, 804, 904, 8, 420.00, 3360.00, 168.00, 3192.00, 240.00, 1112.00, 4);
