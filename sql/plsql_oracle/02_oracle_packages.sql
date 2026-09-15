-- ============================================================================
-- ORACLE PL/SQL MODULAR PACKAGES
-- Specification and Body for Logistics & Inventory Management
-- Maps to CSE3001 Unit 4 (PL/SQL Modular Programming, Stored Procedures/Functions)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- PACKAGE SPECIFICATION: LOGICHAIN_FLEET_PKG
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE logichain_fleet_pkg AS
    -- Custom Record and Table Types
    TYPE t_driver_record IS RECORD (
        emp_id          EMPLOYEE.emp_id%TYPE,
        full_name       VARCHAR2(100),
        salary          EMPLOYEE.salary%TYPE,
        department      EMPLOYEE.department_name%TYPE
    );
    
    TYPE t_driver_table IS TABLE OF t_driver_record INDEX BY PLS_INTEGER;

    -- Stored Procedures & Functions Prototypes
    PROCEDURE get_driver_details(
        p_emp_id         IN  EMPLOYEE.emp_id%TYPE,
        p_driver_name    OUT VARCHAR2,
        p_current_salary OUT NUMBER
    );

    FUNCTION get_depot_location(
        p_emp_id IN EMPLOYEE.emp_id%TYPE
    ) RETURN VARCHAR2;

    PROCEDURE apply_driver_raise(
        p_emp_id     IN EMPLOYEE.emp_id%TYPE,
        p_percentage IN NUMBER DEFAULT 10
    );
END logichain_fleet_pkg;
/

-- ----------------------------------------------------------------------------
-- PACKAGE BODY: LOGICHAIN_FLEET_PKG
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY logichain_fleet_pkg AS

    PROCEDURE get_driver_details(
        p_emp_id         IN  EMPLOYEE.emp_id%TYPE,
        p_driver_name    OUT VARCHAR2,
        p_current_salary OUT NUMBER
    ) IS
    BEGIN
        SELECT first_name || ' ' || last_name, salary
        INTO p_driver_name, p_current_salary
        FROM EMPLOYEE
        WHERE emp_id = p_emp_id;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            p_driver_name := 'UNKNOWN DRIVER';
            p_current_salary := 0;
            RAISE_APPLICATION_ERROR(-20001, 'Driver ID ' || p_emp_id || ' does not exist in the database.');
        WHEN OTHERS THEN
            RAISE_APPLICATION_ERROR(-20002, 'An unexpected error occurred in get_driver_details: ' || SQLERRM);
    END get_driver_details;

    FUNCTION get_depot_location(
        p_emp_id IN EMPLOYEE.emp_id%TYPE
    ) RETURN VARCHAR2 IS
        v_location VARCHAR2(200);
    BEGIN
        SELECT g.city || ', ' || g.state || ' (' || w.warehouse_name || ')'
        INTO v_location
        FROM EMPLOYEE e
        JOIN WAREHOUSE w ON w.manager_id = e.manager_id OR w.warehouse_id = 401
        JOIN GEOGRAPHY_LOCATION g ON w.loc_id = g.loc_id
        WHERE e.emp_id = p_emp_id
          AND ROWNUM = 1;

        RETURN v_location;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Unassigned Central Depot';
    END get_depot_location;

    PROCEDURE apply_driver_raise(
        p_emp_id     IN EMPLOYEE.emp_id%TYPE,
        p_percentage IN NUMBER DEFAULT 10
    ) IS
        v_old_salary NUMBER;
        v_new_salary NUMBER;
    BEGIN
        SELECT salary INTO v_old_salary
        FROM EMPLOYEE
        WHERE emp_id = p_emp_id
        FOR UPDATE;

        v_new_salary := ROUND(v_old_salary * (1 + (p_percentage / 100)), 2);

        UPDATE EMPLOYEE
        SET salary = v_new_salary
        WHERE emp_id = p_emp_id;

        DBMS_OUTPUT.PUT_LINE('Salary for Driver ' || p_emp_id || ' adjusted from ' || v_old_salary || ' to ' || v_new_salary);
    END apply_driver_raise;

END logichain_fleet_pkg;
/
