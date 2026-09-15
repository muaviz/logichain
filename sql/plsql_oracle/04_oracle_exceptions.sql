-- ============================================================================
-- ORACLE PL/SQL EXCEPTION HANDLING & CUSTOM ERROR SIGNALS
-- Maps to CSE3001 Lab 7, Lab 10, and Unit 4
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. USER-DEFINED EXCEPTION: BUSINESS MUTUAL EXCLUSIVITY (Syllabus Lab 7 Equivalent)
-- ----------------------------------------------------------------------------
DECLARE
    e_role_conflict EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_role_conflict, -20015);

    v_shipment_id  NUMBER := 901;
    v_driver_id    NUMBER := 8;
    v_inspector_id NUMBER := 8; -- Intentional conflict: same employee
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TESTING DISPATCH SEPARATION OF DUTIES ===');

    IF v_driver_id = v_inspector_id THEN
        RAISE e_role_conflict;
    END IF;

    -- Proceed with assignment
    UPDATE SHIPMENT
    SET driver_id = v_driver_id,
        inspector_id = v_inspector_id
    WHERE shipment_id = v_shipment_id;

    DBMS_OUTPUT.PUT_LINE('Shipment successfully assigned.');
EXCEPTION
    WHEN e_role_conflict THEN
        DBMS_OUTPUT.PUT_LINE('ERROR CAUGHT: Employee ' || v_driver_id || ' cannot serve as both Driver and Inspector on Shipment ' || v_shipment_id || '!');
        RAISE_APPLICATION_ERROR(-20015, 'Integrity Violation: Driver and Quality Inspector must be distinct staff.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unhandled exception: ' || SQLERRM);
END;
/

-- ----------------------------------------------------------------------------
-- 2. DML BLOCKING TRIGGER WITH USER-DEFINED ERROR (Syllabus Lab 10 Equivalent)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER trg_oracle_block_unauthorized_dml
BEFORE INSERT OR UPDATE ON CUSTOMER
FOR EACH ROW
BEGIN
    IF :NEW.credit_limit > 1000000.00 THEN
        RAISE_APPLICATION_ERROR(-20020, 'ERR-30010: Unauthorized Credit Limit. Credit limits exceeding $1,000,000 require Board of Directors approval.');
    END IF;
END;
/
