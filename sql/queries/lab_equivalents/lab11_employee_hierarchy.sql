-- ============================================================================
-- LAB 11 EQUIVALENT: EMPLOYEE & DEPARTMENT HIERARCHY JOIN QUERIES
-- Maps to CSE3001 Lab 11 (Self-Joins, Boss Hierarchy, Outer Joins, Aggregation)
-- ============================================================================

-- Query 1: Display the name of each employee with his/her department name
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    e.department_name,
    e.job_role
FROM EMPLOYEE e
ORDER BY e.department_name, employee_name;

-- Query 2: Display a list of all departments with the employees in each department
SELECT 
    e.department_name,
    e.emp_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.job_role,
    e.salary
FROM EMPLOYEE e
ORDER BY e.department_name, e.salary DESC;

-- Query 3: Display all the departments with the manager for that department
SELECT 
    d.department_name,
    m.emp_id AS manager_id,
    m.first_name || ' ' || m.last_name AS manager_name,
    m.job_role AS manager_role
FROM (SELECT DISTINCT department_name FROM EMPLOYEE) d
JOIN EMPLOYEE m ON m.department_name = d.department_name
WHERE m.manager_id IS NULL OR m.job_role LIKE '%President%' OR m.job_role LIKE '%VP%' OR m.job_role LIKE '%Director%' OR m.job_role LIKE '%Manager%'
ORDER BY d.department_name;

-- Query 4: Display the names of each employee with the name of his/her boss (Inner Join)
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    m.first_name || ' ' || m.last_name AS boss_name
FROM EMPLOYEE e
JOIN EMPLOYEE m ON e.manager_id = m.emp_id;

-- Query 5: Display the names of each employee with the name of his/her boss with a BLANK for the boss of the president (Left Outer Join + COALESCE)
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    COALESCE(m.first_name || ' ' || m.last_name, '') AS boss_name,
    e.job_role
FROM EMPLOYEE e
LEFT JOIN EMPLOYEE m ON e.manager_id = m.emp_id
ORDER BY e.emp_id;

-- Query 6: Display employee number and name of each employee who manages other employees with the count of people managed
SELECT 
    m.emp_id AS manager_emp_id,
    m.first_name || ' ' || m.last_name AS manager_name,
    m.job_role,
    COUNT(e.emp_id) AS employees_managed_count
FROM EMPLOYEE m
JOIN EMPLOYEE e ON e.manager_id = m.emp_id
GROUP BY m.emp_id, m.first_name, m.last_name, m.job_role;

-- Query 7: Repeat the display for the last question, ordered descending by the number of employees managed
SELECT 
    m.emp_id AS manager_emp_id,
    m.first_name || ' ' || m.last_name AS manager_name,
    m.job_role,
    COUNT(e.emp_id) AS employees_managed_count
FROM EMPLOYEE m
JOIN EMPLOYEE e ON e.manager_id = m.emp_id
GROUP BY m.emp_id, m.first_name, m.last_name, m.job_role
ORDER BY employees_managed_count DESC, manager_name ASC;
