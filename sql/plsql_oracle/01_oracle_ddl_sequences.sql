-- ============================================================================
-- ORACLE 19c / 21c PL/SQL COMPATIBILITY SUITE
-- Native Oracle DDL, Sequences, Synonyms, and Data Dictionary Views
-- Maps to CSE3001 Unit 3 & Unit 4
-- ============================================================================

-- 1. Sequences for Auto-Incrementing Primary Keys
CREATE SEQUENCE seq_geography_id START WITH 200 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_employee_id START WITH 100 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_supplier_id START WITH 300 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_product_id START WITH 500 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_order_id START WITH 1000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_shipment_id START WITH 2000 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_audit_id START WITH 1 INCREMENT BY 1 NOCACHE;

-- 2. Oracle Data Dictionary Views Query Examples (Unit 3)
-- SELECT table_name, tablespace_name, status FROM user_tables;
-- SELECT sequence_name, min_value, max_value, last_number FROM user_sequences;
-- SELECT view_name, text FROM user_views;
-- SELECT trigger_name, trigger_type, triggering_event, status FROM user_triggers;

-- 3. Public and Private Synonyms (Unit 3)
-- CREATE SYNONYM syn_client_master FOR CUSTOMER;
-- CREATE SYNONYM syn_parts_catalog FOR PRODUCT;
-- CREATE SYNONYM syn_audit_trail FOR AUDIT_CLIENT_LOG;
