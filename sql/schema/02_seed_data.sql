-- ============================================================================
-- LOGICHAIN SEED DATA INITIALIZATION SCRIPT
-- Comprehensive relational dataset for tests, benchmarks, and lab queries
-- ============================================================================

-- 1. GEOGRAPHY_LOCATION
INSERT INTO GEOGRAPHY_LOCATION (loc_id, city, region, state, country, postal_code, latitude, longitude) VALUES
(101, 'New York', 'Northeast', 'NY', 'USA', '10001', 40.7128, -74.0060),
(102, 'Los Angeles', 'West', 'CA', 'USA', '90001', 34.0522, -118.2437),
(103, 'Chicago', 'Midwest', 'IL', 'USA', '60601', 41.8781, -87.6298),
(104, 'Houston', 'South', 'TX', 'USA', '77001', 29.7604, -95.3698),
(105, 'Phoenix', 'Southwest', 'AZ', 'USA', '85001', 33.4484, -112.0740),
(106, 'Philadelphia', 'Northeast', 'PA', 'USA', '19101', 39.9526, -75.1652),
(107, 'San Antonio', 'South', 'TX', 'USA', '78201', 29.4241, -98.4936),
(108, 'San Diego', 'West', 'CA', 'USA', '92101', 32.7157, -117.1611),
(109, 'Dallas', 'South', 'TX', 'USA', '75201', 32.7767, -96.7970),
(110, 'San Jose', 'West', 'CA', 'USA', '95101', 37.3382, -121.8863),
(111, 'Seattle', 'Northwest', 'WA', 'USA', '98101', 47.6062, -122.3321),
(112, 'Boston', 'Northeast', 'MA', 'USA', '02101', 42.3601, -71.0589),
(113, 'Denver', 'Mountain', 'CO', 'USA', '80201', 39.7392, -104.9903),
(114, 'Miami', 'Southeast', 'FL', 'USA', '33101', 25.7617, -80.1918),
(115, 'Atlanta', 'Southeast', 'GA', 'USA', '30301', 33.7490, -84.3880);

-- 2. EMPLOYEE (Boss & Department Hierarchy - Lab 11)
-- emp_id 1 is the President (manager_id NULL)
INSERT INTO EMPLOYEE (emp_id, first_name, last_name, email, phone, hire_date, job_role, department_name, salary, commission_pct, manager_id, is_active) VALUES
(1, 'Eleanor', 'Vance', 'eleanor.vance@logichain.io', '212-555-0100', '2015-01-10', 'President & CEO', 'Executive', 250000.00, 0.15, NULL, 1),
(2, 'Marcus', 'Sterling', 'marcus.s@logichain.io', '212-555-0101', '2016-03-15', 'VP of Logistics', 'Logistics', 160000.00, 0.10, 1, 1),
(3, 'Sophia', 'Rodriguez', 'sophia.r@logichain.io', '212-555-0102', '2016-06-01', 'VP of Operations', 'Operations', 155000.00, 0.08, 1, 1),
(4, 'David', 'Kim', 'david.k@logichain.io', '212-555-0103', '2017-02-12', 'Logistics Director East', 'Logistics', 115000.00, 0.05, 2, 1),
(5, 'Rachel', 'Patel', 'rachel.p@logichain.io', '212-555-0104', '2017-05-20', 'Logistics Director West', 'Logistics', 112000.00, 0.05, 2, 1),
(6, 'Thomas', 'Wright', 'thomas.w@logichain.io', '212-555-0105', '2018-01-15', 'Warehouse Hub Manager NYC', 'Operations', 88000.00, 0.03, 3, 1),
(7, 'Elena', 'Gomez', 'elena.g@logichain.io', '212-555-0106', '2018-04-10', 'Warehouse Hub Manager LAX', 'Operations', 86000.00, 0.03, 3, 1),
(8, 'Rajesh', 'Kumar', 'rajesh.k@logichain.io', '212-555-0107', '2019-03-01', 'Senior Fleet Driver', 'Logistics', 75000.00, 0.02, 4, 1),
(9, 'Carlos', 'Mendoza', 'carlos.m@logichain.io', '212-555-0108', '2019-07-15', 'Senior Fleet Driver', 'Logistics', 72000.00, 0.02, 5, 1),
(10, 'Aisha', 'Al-Mansoor', 'aisha.a@logichain.io', '212-555-0109', '2020-02-01', 'Fleet Driver', 'Logistics', 65000.00, 0.01, 4, 1),
(11, 'Liam', 'O''Connor', 'liam.o@logichain.io', '212-555-0110', '2020-09-10', 'Fleet Driver', 'Logistics', 63000.00, 0.01, 5, 1),
(12, 'James', 'Wilson', 'james.w@logichain.io', '212-555-0111', '2021-01-18', 'Quality Inspector', 'Operations', 68000.00, 0.00, 6, 1),
(13, 'Maria', 'Santos', 'maria.s@logichain.io', '212-555-0112', '2021-05-12', 'Quality Inspector', 'Operations', 67000.00, 0.00, 7, 1),
(14, 'Kevin', 'Chen', 'kevin.c@logichain.io', '212-555-0113', '2022-03-01', 'Warehouse Clerk', 'Operations', 48000.00, 0.00, 6, 1),
(15, 'Sarah', 'Jenkins', 'sarah.j@logichain.io', '212-555-0114', '2022-06-15', 'Warehouse Clerk', 'Operations', 47000.00, 0.00, 7, 1);

-- 3. EMPLOYEE_DEPENDENT (Weak Entity)
INSERT INTO EMPLOYEE_DEPENDENT (emp_id, dependent_name, relationship, birth_date, gender) VALUES
(1, 'Arthur Vance', 'Spouse', '1978-04-12', 'Male'),
(1, 'Clara Vance', 'Child', '2010-09-22', 'Female'),
(4, 'Hannah Kim', 'Spouse', '1985-11-05', 'Female'),
(4, 'Lucas Kim', 'Child', '2015-08-14', 'Male'),
(8, 'Priya Kumar', 'Spouse', '1990-02-18', 'Female'),
(8, 'Aarav Kumar', 'Child', '2018-05-30', 'Male');

-- 4. SUPPLIER
INSERT INTO SUPPLIER (supplier_id, company_name, contact_name, contact_email, contact_phone, loc_id, tax_id, rating, is_active) VALUES
(201, 'TimberCraft Industrial Wood', 'Jonathan Miller', 'orders@timbercraft.com', '503-555-0201', 111, 'TAX-9901-WA', 5, 1),
(202, 'Apex Steel & Alloys', 'Vikram Malhotra', 'sales@apexsteel.com', '312-555-0202', 103, 'TAX-9902-IL', 4, 1),
(203, 'Global Polymer Solutions', 'Claire Dupont', 'info@globalpoly.com', '713-555-0203', 104, 'TAX-9903-TX', 4, 1),
(204, 'Starlight Marble & Stone', 'Gianni Rossi', 'support@starlightmarble.com', '617-555-0204', 112, 'TAX-9904-MA', 5, 1),
(205, 'Nordic Glassworks LLC', 'Astrid Lind', 'b2b@nordicglass.com', '206-555-0205', 111, 'TAX-9905-WA', 3, 1),
(206, 'Evergreen Packaging Corp', 'Samuel Briggs', 'sales@evergreenpkg.com', '404-555-0206', 115, 'TAX-9906-GA', 4, 1);

-- 5. PRODUCT_CATEGORY
INSERT INTO PRODUCT_CATEGORY (category_id, category_name, department, parent_category_id) VALUES
(1, 'Industrial Raw Materials', 'Heavy Industry', NULL),
(2, 'Commercial Furniture', 'Furnishings', NULL),
(3, 'Packaging & Logistics Supplies', 'Supplies', NULL),
(4, 'Solid Wood Lumber', 'Heavy Industry', 1),
(5, 'Structural Steel Parts', 'Heavy Industry', 1),
(6, 'Office Desks & Workstations', 'Furnishings', 2),
(7, 'Ergonomic Seating', 'Furnishings', 2),
(8, 'Conference & Dining Tables', 'Furnishings', 2),
(9, 'Storage Cabinets & Racks', 'Furnishings', 2);

-- 6. PRODUCT
INSERT INTO PRODUCT (product_id, sku, product_name, category_id, material_type, unit_weight_kg, base_price, reorder_threshold, is_discontinued) VALUES
(301, 'WD-OAK-001', 'Solid Oak Heavy Duty Desktop', 6, 'Wood', 28.50, 249.99, 15, 0),
(302, 'WD-WAL-002', 'Walnut Executive Conference Table', 8, 'Wood', 85.00, 899.50, 5, 0),
(303, 'ST-FRM-003', 'Steel Modular Desk Frame', 6, 'Steel', 18.20, 159.00, 20, 0),
(304, 'CH-ERG-004', 'AeroFlex Mesh Ergonomic Task Chair', 7, 'Polymer', 14.00, 199.99, 25, 0),
(305, 'CH-LTH-005', 'Executive High-Back Leather Chair', 7, 'Leather', 22.00, 349.00, 10, 0),
(306, 'MB-TAB-006', 'Italian Carrara Marble Coffee Table', 8, 'Marble', 62.00, 650.00, 8, 0),
(307, 'CB-STL-007', 'Heavy Duty 4-Drawer Steel Cabinet', 9, 'Steel', 45.00, 280.00, 12, 0),
(308, 'CB-WOD-008', 'Nordic Pine Modular Wardrobe Unit', 9, 'Wood', 58.00, 420.00, 10, 0),
(309, 'PL-CRG-009', 'Heavy Duty Industrial Pallet 120x80', 3, 'Wood', 22.00, 35.00, 100, 0),
(310, 'GL-PNL-010', 'Tempered Glass Acoustic Partition', 6, 'Glass', 31.00, 310.00, 10, 0);

-- 7. SUPPLIER_PRODUCT (M:N Catalog)
INSERT INTO SUPPLIER_PRODUCT (supplier_id, product_id, supply_price, lead_time_days, minimum_order_qty) VALUES
(201, 301, 140.00, 4, 10),
(201, 302, 520.00, 7, 2),
(201, 308, 230.00, 5, 5),
(201, 309, 18.00, 2, 50),
(202, 303, 85.00, 3, 20),
(202, 307, 160.00, 5, 10),
(203, 304, 95.00, 4, 15),
(204, 306, 380.00, 10, 3),
(205, 310, 175.00, 6, 5),
(206, 309, 20.00, 1, 100);

-- 8. WAREHOUSE
INSERT INTO WAREHOUSE (warehouse_id, warehouse_code, warehouse_name, loc_id, manager_id, total_capacity_sqft, is_operational) VALUES
(401, 'WH-NYC-01', 'LogiChain Northeast Metro Hub', 101, 6, 120000, 1),
(402, 'WH-LAX-02', 'LogiChain Pacific Gateway Depot', 102, 7, 150000, 1),
(403, 'WH-CHI-03', 'LogiChain Midwest Central Terminal', 103, 6, 95000, 1),
(404, 'WH-HOU-04', 'LogiChain Gulf Logistics Center', 104, 7, 110000, 1);

-- 9. WAREHOUSE_BIN (Weak Entity)
INSERT INTO WAREHOUSE_BIN (warehouse_id, bin_code, aisle, rack, shelf_level, zone_type, max_volume_cbm) VALUES
(401, 'BIN-A1-01', 'A1', 'R01', 1, 'FAST_PICK', 8.5),
(401, 'BIN-A1-02', 'A1', 'R01', 2, 'FAST_PICK', 8.5),
(401, 'BIN-B2-01', 'B2', 'R04', 1, 'BULK_STORAGE', 25.0),
(401, 'BIN-C3-01', 'C3', 'R08', 3, 'HAZMAT_SECURE', 10.0),
(402, 'BIN-A1-01', 'A1', 'R01', 1, 'FAST_PICK', 12.0),
(402, 'BIN-B1-01', 'B1', 'R03', 1, 'BULK_STORAGE', 30.0),
(403, 'BIN-A1-01', 'A1', 'R01', 1, 'FAST_PICK', 10.0),
(404, 'BIN-A1-01', 'A1', 'R01', 1, 'FAST_PICK', 15.0);

-- 10. INVENTORY_STOCK
INSERT INTO INVENTORY_STOCK (stock_id, warehouse_id, bin_code, product_id, quantity_on_hand, quantity_reserved, last_restock_date) VALUES
(501, 401, 'BIN-A1-01', 301, 150, 20, '2026-08-01'),
(502, 401, 'BIN-A1-02', 304, 220, 35, '2026-08-10'),
(503, 401, 'BIN-B2-01', 303, 400, 50, '2026-08-15'),
(504, 401, 'BIN-B2-01', 307, 85, 10, '2026-08-20'),
(505, 402, 'BIN-A1-01', 301, 90, 15, '2026-08-05'),
(506, 402, 'BIN-A1-01', 302, 35, 5, '2026-08-12'),
(507, 402, 'BIN-B1-01', 306, 40, 8, '2026-08-18'),
(508, 403, 'BIN-A1-01', 305, 75, 12, '2026-08-22'),
(509, 404, 'BIN-A1-01', 309, 600, 100, '2026-08-25');

-- 11. VEHICLE_TYPE
INSERT INTO VEHICLE_TYPE (type_code, type_name, max_payload_kg, cruising_range_km, requires_special_license) VALUES
('SEMI_HEAVY', 'Freightliner Cascadia Class 8 Semi', 22000.00, 1800, 1),
('MEDIUM_VAN', 'Mercedes Sprinter Cargo 3500', 3500.00, 850, 0),
('REEFER_TRUCK', 'Volvo VNR Refrigerated Cargo', 14000.00, 1200, 1),
('ELECTRIC_VAN', 'Rivian EDV Commercial 700', 2500.00, 400, 0),
('BOEING_AIR_747', 'Boeing 747-8F Heavy Air Freighter', 137000.00, 8100, 1); -- Syllabus Lab 1 Flight equivalent

-- 12. VEHICLE
INSERT INTO VEHICLE (vehicle_id, vin, license_plate, type_code, current_warehouse_id, status, total_km_driven, last_maintenance_date) VALUES
(601, '1FUJBBCK4NL123456', 'NY-TRK-7890', 'SEMI_HEAVY', 401, 'AVAILABLE', 45000, '2026-07-15'),
(602, '1FUJBBCK4NL654321', 'NY-VAN-1122', 'MEDIUM_VAN', 401, 'AVAILABLE', 28000, '2026-08-01'),
(603, '4V4NC9EH8MN987654', 'CA-TRK-4433', 'SEMI_HEAVY', 402, 'AVAILABLE', 62000, '2026-07-20'),
(604, '4V4NC9EH8MN332211', 'CA-REF-9988', 'REEFER_TRUCK', 402, 'AVAILABLE', 35000, '2026-08-10'),
(605, '7FVRG2389PL554433', 'IL-ELV-7766', 'ELECTRIC_VAN', 403, 'AVAILABLE', 12000, '2026-08-15'),
(606, 'BOEING-CARGO-747X', 'N747LC-AIR', 'BOEING_AIR_747', 401, 'AVAILABLE', 150000, '2026-06-30');

-- 13. DRIVER_CERTIFICATION (Pilot/Driver Certifications - Lab 1)
INSERT INTO DRIVER_CERTIFICATION (emp_id, type_code, certification_number, issue_date, expiry_date) VALUES
(8, 'SEMI_HEAVY', 'CDL-NY-88991', '2022-01-10', '2027-01-10'),
(8, 'MEDIUM_VAN', 'CDL-NY-88992', '2021-05-15', '2027-05-15'),
(8, 'BOEING_AIR_747', 'FAA-ATP-99001', '2020-03-12', '2028-03-12'), -- Certified for Boeing
(9, 'SEMI_HEAVY', 'CDL-CA-77112', '2021-08-20', '2026-08-20'),
(9, 'REEFER_TRUCK', 'CDL-CA-77113', '2022-02-14', '2027-02-14'),
(10, 'MEDIUM_VAN', 'CDL-NY-55331', '2023-01-10', '2028-01-10'),
(10, 'ELECTRIC_VAN', 'CDL-NY-55332', '2023-04-15', '2028-04-15'),
(11, 'MEDIUM_VAN', 'CDL-CA-44221', '2023-02-20', '2028-02-20');

-- 14. CUSTOMER (Client Master - Lab 5)
INSERT INTO CUSTOMER (customer_id, customer_code, company_name, contact_name, contact_email, contact_phone, loc_id, credit_limit, balance_due, status) VALUES
(701, 'CUST-METRO-01', 'Metro Workspace Solutions Inc', 'Arthur Dent', 'adent@metroworkspace.com', '212-555-0701', 101, 50000.00, 12500.00, 'ACTIVE'),
(702, 'CUST-PACIFIC-02', 'Pacific Design Studio', 'Trillian Astra', 'tastra@pacificdesign.com', '213-555-0702', 102, 40000.00, 8400.00, 'ACTIVE'),
(703, 'CUST-MIDWEST-03', 'Windy City Office Supplies', 'Ford Prefect', 'fprefect@windycityoff.com', '312-555-0703', 103, 30000.00, 0.00, 'ACTIVE'),
(704, 'CUST-TEXAS-04', 'Lone Star Corporate Interiors', 'Zaphod Beeblebrox', 'president@lonestarcorp.com', '713-555-0704', 104, 75000.00, 24500.00, 'ACTIVE'),
(705, 'CUST-SEATTLE-05', 'Sound Tech Furnishings', 'Tricia McMillan', 'tmcmillan@soundtech.com', '206-555-0705', 111, 35000.00, 3200.00, 'ACTIVE'),
(706, 'CUST-BOSTON-06', 'Beacon Hill Commercial Interiors', 'Rajesh Sharma', 'rsharma@beaconhill.com', '617-555-0706', 112, 60000.00, 15000.00, 'ACTIVE');

-- 15. CUSTOMER_ORDER
INSERT INTO CUSTOMER_ORDER (order_id, order_number, customer_id, order_date, required_date, shipped_date, status, subtotal, discount_pct, tax_amount, total_amount) VALUES
(801, 'ORD-2026-001', 701, '2026-08-01', '2026-08-10', '2026-08-03', 'DELIVERED', 4999.80, 0.05, 379.98, 5129.79),
(802, 'ORD-2026-002', 702, '2026-08-05', '2026-08-15', '2026-08-07', 'DELIVERED', 8995.00, 0.10, 647.64, 8743.14),
(803, 'ORD-2026-003', 703, '2026-08-12', '2026-08-20', '2026-08-14', 'DELIVERED', 2800.00, 0.00, 224.00, 3024.00),
(804, 'ORD-2026-004', 704, '2026-08-18', '2026-08-28', '2026-08-20', 'SHIPPED', 12450.00, 0.08, 916.32, 12370.32),
(805, 'ORD-2026-005', 705, '2026-08-25', '2026-09-05', NULL, 'PROCESSING', 3490.00, 0.00, 279.20, 3769.20),
(806, 'ORD-2026-006', 706, '2026-08-28', '2026-09-08', NULL, 'PENDING', 7200.00, 0.05, 547.20, 7387.20);

-- 16. ORDER_ITEM
INSERT INTO ORDER_ITEM (order_id, item_seq, product_id, ordered_qty, unit_price, discount_rate, line_total) VALUES
(801, 1, 301, 10, 249.99, 0.05, 2374.91),
(801, 2, 304, 10, 199.99, 0.05, 1899.91),
(801, 3, 303, 5, 159.00, 0.00, 795.00),
(802, 1, 302, 10, 899.50, 0.10, 8095.50),
(802, 2, 305, 3, 349.00, 0.00, 1047.00),
(803, 1, 307, 10, 280.00, 0.00, 2800.00),
(804, 1, 306, 15, 650.00, 0.08, 8970.00),
(804, 2, 308, 8, 420.00, 0.05, 3192.00),
(805, 1, 305, 10, 349.00, 0.00, 3490.00),
(806, 1, 301, 20, 249.99, 0.05, 4749.81),
(806, 2, 304, 12, 199.99, 0.05, 2279.89);

-- 17. SHIPMENT
INSERT INTO SHIPMENT (shipment_id, shipment_code, order_id, origin_warehouse_id, vehicle_id, driver_id, inspector_id, dispatch_date, delivery_date, status, freight_cost) VALUES
(901, 'SHP-2026-001', 801, 401, 601, 8, 12, '2026-08-03 08:30:00', '2026-08-03 16:45:00', 'DELIVERED', 280.00),
(902, 'SHP-2026-002', 802, 402, 603, 9, 13, '2026-08-07 09:15:00', '2026-08-08 14:20:00', 'DELIVERED', 450.00),
(903, 'SHP-2026-003', 803, 401, 602, 10, 12, '2026-08-14 10:00:00', '2026-08-15 11:30:00', 'DELIVERED', 195.00),
(904, 'SHP-2026-004', 804, 402, 604, 9, 13, '2026-08-20 07:45:00', NULL, 'IN_TRANSIT', 620.00);

-- 18. SHIPMENT_ITEM (Weak Entity)
INSERT INTO SHIPMENT_ITEM (shipment_id, item_seq, product_id, quantity_shipped, unit_price) VALUES
(901, 1, 301, 10, 249.99),
(901, 2, 304, 10, 199.99),
(901, 3, 303, 5, 159.00),
(902, 1, 302, 10, 899.50),
(902, 2, 305, 3, 349.00),
(903, 1, 307, 10, 280.00),
(904, 1, 306, 15, 650.00),
(904, 2, 308, 8, 420.00);

-- 19. AUDIT_CLIENT_LOG (Initial Audit Records)
INSERT INTO AUDIT_CLIENT_LOG (audit_id, customer_id, company_name, old_balance_due, new_balance_due, operation, db_user, changed_at) VALUES
(1, 701, 'Metro Workspace Solutions Inc', 0.00, 12500.00, 'INSERT', 'ADMIN_LOADER', '2026-08-01 00:00:00'),
(2, 704, 'Lone Star Corporate Interiors', 0.00, 24500.00, 'INSERT', 'ADMIN_LOADER', '2026-08-01 00:00:00');
