-- ============================================================================
-- PL/pgSQL PROCEDURES & FUNCTIONS: EMPLOYEE DETAILS & SALARY ADJUSTMENT (Lab 8 & 9)
-- Demonstrates IN/OUT parameters, Stored Functions callable in SQL queries
-- ============================================================================

-- Function 1: Get Employee / Driver Depot Location (Callable inside SQL SELECT statements)
CREATE OR REPLACE FUNCTION fn_get_driver_depot_location(p_emp_id INTEGER)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
    v_address VARCHAR;
BEGIN
    SELECT g.city || ', ' || g.state || ' (' || w.warehouse_name || ')'
    INTO v_address
    FROM EMPLOYEE e
    JOIN WAREHOUSE w ON w.manager_id = e.manager_id OR w.warehouse_id = 401
    JOIN GEOGRAPHY_LOCATION g ON w.loc_id = g.loc_id
    WHERE e.emp_id = p_emp_id
    LIMIT 1;

    IF v_address IS NULL THEN
        v_address := 'Unassigned Headquarters Terminal';
    END IF;

    RETURN v_address;
END;
$$;

-- Procedure 2: Get Driver / Cleaner Details with IN/OUT Parameters & 10% raise calculation (Lab 8 & 9)
CREATE OR REPLACE PROCEDURE sp_get_employee_details_and_raise(
    IN p_emp_id INTEGER,
    OUT p_full_name VARCHAR,
    OUT p_current_salary DECIMAL(12, 2),
    OUT p_revised_salary DECIMAL(12, 2)
)
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT first_name || ' ' || last_name, salary
    INTO p_full_name, p_current_salary
    FROM EMPLOYEE
    WHERE emp_id = p_emp_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Employee ID % does not exist.', p_emp_id;
    END IF;

    -- Calculate 10% increase
    p_revised_salary := ROUND(p_current_salary * 1.10, 2);

    -- Apply raise in table
    UPDATE EMPLOYEE
    SET salary = p_revised_salary
    WHERE emp_id = p_emp_id;
END;
$$;
