-- ============================================================================
-- ORACLE STORED PROCEDURES & FUNCTIONS WITH IN/OUT PARAMETERS
-- Maps to CSE3001 Lab 8 & Lab 9
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. STORED PROCEDURE: getCleanerDetails / getDriverDetails (Lab 8 & 9)
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE getCleanerDetails (
    p_cleaner_no IN  NUMBER,
    p_name       OUT VARCHAR2,
    p_salary     OUT NUMBER
) IS
BEGIN
    SELECT first_name || ' ' || last_name, salary
    INTO p_name, p_salary
    FROM EMPLOYEE
    WHERE emp_id = p_cleaner_no;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        p_name := 'NOT FOUND';
        p_salary := 0.00;
        DBMS_OUTPUT.PUT_LINE('No employee record found for ID: ' || p_cleaner_no);
END;
/

-- ----------------------------------------------------------------------------
-- 2. STORED FUNCTION: getCleanersLocation / getDepotLocation (Lab 8)
-- Callable from within a standard SQL SELECT statement
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION getCleanersLocation (
    p_cleaner_no IN NUMBER
) RETURN VARCHAR2 IS
    v_address VARCHAR2(250);
BEGIN
    SELECT g.city || ', ' || g.state || ' - Hub: ' || w.warehouse_name
    INTO v_address
    FROM EMPLOYEE e
    LEFT JOIN WAREHOUSE w ON w.manager_id = e.manager_id OR w.warehouse_id = 401
    LEFT JOIN GEOGRAPHY_LOCATION g ON w.loc_id = g.loc_id
    WHERE e.emp_id = p_cleaner_no
      AND ROWNUM = 1;

    RETURN NVL(v_address, 'Unassigned Regional Depot');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'Unknown Location';
END;
/

-- ----------------------------------------------------------------------------
-- 3. SQL SELECT STATEMENT CALLING STORED FUNCTION (Lab 8 Requirement)
-- ----------------------------------------------------------------------------
-- SELECT emp_id, first_name || ' ' || last_name AS emp_name, getCleanersLocation(emp_id) AS depot_location
-- FROM EMPLOYEE
-- WHERE emp_id = 8;

-- ----------------------------------------------------------------------------
-- 4. MAIN PL/SQL BLOCK CALLING PROCEDURE WITH 10% SALARY RAISE (Lab 9 Requirement)
-- ----------------------------------------------------------------------------
DECLARE
    v_target_id    NUMBER := 8; -- Tested with employee ID 8 (or 113)
    v_emp_name     VARCHAR2(100);
    v_orig_salary  NUMBER;
    v_bumped_salary NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== EXECUTING LAB 8/9 PROCEDURE & SALARY ADJUSTMENT ===');

    -- Call procedure to retrieve details via OUT parameters
    getCleanerDetails(v_target_id, v_emp_name, v_orig_salary);

    IF v_orig_salary > 0 THEN
        -- Calculate 10% increase
        v_bumped_salary := ROUND(v_orig_salary * 1.10, 2);

        DBMS_OUTPUT.PUT_LINE('Staff ID          : ' || v_target_id);
        DBMS_OUTPUT.PUT_LINE('Staff Name        : ' || v_emp_name);
        DBMS_OUTPUT.PUT_LINE('Original Salary   : $' || TO_CHAR(v_orig_salary, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('Revised (+10%)    : $' || TO_CHAR(v_bumped_salary, '999,999.99'));
        DBMS_OUTPUT.PUT_LINE('Assigned Location : ' || getCleanersLocation(v_target_id));
    END IF;
END;
/
