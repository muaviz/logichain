-- ============================================================================
-- LAB 2 EQUIVALENT: COMPLETE 25-QUERY BENCHMARK CATALOG
-- Direct 1:1 mapping of all 25 Sailor/Boat/Reserves queries from CSE3001 Lab 2
-- Schema: DRIVERS (EMPLOYEE), VEHICLES (VEHICLE + VEHICLE_TYPE), SHIPMENTS (SHIPMENT)
-- ============================================================================

-- Q1: Display names & hire dates/ages of all drivers
SELECT first_name || ' ' || last_name AS driver_name, hire_date, salary
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%';

-- Q2: Find all drivers with salary above $70,000 (rating above 7)
SELECT emp_id, first_name || ' ' || last_name AS driver_name, salary
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%' AND salary > 70000;

-- Q3: Display all names & types of the fleet vehicles (names & colors of boats)
SELECT v.vehicle_id, v.license_plate, vt.type_name, v.status
FROM VEHICLE v
JOIN VEHICLE_TYPE vt ON v.type_code = vt.type_code;

-- Q4: Find all vehicles of type 'SEMI_HEAVY' (boats with Red color)
SELECT v.vehicle_id, v.license_plate, vt.type_name
FROM VEHICLE v
JOIN VEHICLE_TYPE vt ON v.type_code = vt.type_code
WHERE vt.type_code = 'SEMI_HEAVY';

-- Q5: Find names of drivers who have operated/dispatched vehicle 601 (reserved boat 123)
SELECT DISTINCT e.first_name || ' ' || e.last_name AS driver_name
FROM EMPLOYEE e
JOIN SHIPMENT s ON e.emp_id = s.driver_id
WHERE s.vehicle_id = 601;

-- Q6: Find IDs of drivers who have operated 'REEFER_TRUCK' (reserved Pink boat)
SELECT DISTINCT s.driver_id
FROM SHIPMENT s
JOIN VEHICLE v ON s.vehicle_id = v.vehicle_id
WHERE v.type_code = 'REEFER_TRUCK';

-- Q7: Find the vehicle types driven by 'Rajesh' (color of boats reserved by Rajesh)
SELECT DISTINCT vt.type_name
FROM EMPLOYEE e
JOIN SHIPMENT s ON e.emp_id = s.driver_id
JOIN VEHICLE v ON s.vehicle_id = v.vehicle_id
JOIN VEHICLE_TYPE vt ON v.type_code = vt.type_code
WHERE e.first_name = 'Rajesh';

-- Q8: Find names of drivers who have completed at least one shipment
SELECT DISTINCT e.first_name || ' ' || e.last_name AS driver_name
FROM EMPLOYEE e
JOIN SHIPMENT s ON e.emp_id = s.driver_id;

-- Q9: Find names of drivers who have operated a Semi or a Reefer vehicle (red or green boat)
SELECT DISTINCT e.first_name || ' ' || e.last_name AS driver_name
FROM EMPLOYEE e
JOIN SHIPMENT s ON e.emp_id = s.driver_id
JOIN VEHICLE v ON s.vehicle_id = v.vehicle_id
WHERE v.type_code IN ('SEMI_HEAVY', 'REEFER_TRUCK');

-- Q10: Find names of drivers who have operated vehicle 601 (reserved boat 103)
SELECT DISTINCT e.first_name || ' ' || e.last_name AS driver_name
FROM EMPLOYEE e
JOIN SHIPMENT s ON e.emp_id = s.driver_id
WHERE s.vehicle_id = 601;

-- Q11: Find names of drivers who have NOT operated vehicle 601 (not reserved boat 103)
SELECT first_name || ' ' || last_name AS driver_name
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%'
  AND emp_id NOT IN (
      SELECT driver_id FROM SHIPMENT WHERE vehicle_id = 601
  );

-- Q12: Find drivers whose salary is higher than some driver called 'Rajesh'
SELECT emp_id, first_name || ' ' || last_name AS driver_name, salary
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%'
  AND salary > (
      SELECT salary FROM EMPLOYEE WHERE first_name = 'Rajesh' AND job_role LIKE '%Driver%' LIMIT 1
  );

-- Q13: Find the driver with the highest salary using ALL operator (PostgreSQL/Oracle: '>= ALL', SQLite: '>= (SELECT MAX...)')
-- Standard Oracle/PostgreSQL:
-- SELECT emp_id, first_name || ' ' || last_name AS driver_name, salary
-- FROM EMPLOYEE WHERE job_role LIKE '%Driver%' AND salary >= ALL (SELECT salary FROM EMPLOYEE WHERE job_role LIKE '%Driver%');
SELECT emp_id, first_name || ' ' || last_name AS driver_name, salary
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%'
  AND salary >= (
      SELECT MAX(salary) FROM EMPLOYEE WHERE job_role LIKE '%Driver%'
  );

-- Q14: Count total number of driver IDs in the system
SELECT COUNT(emp_id) AS total_driver_count
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%';

-- Q15: Count number of shipments dispatched in the SHIPMENT table
SELECT COUNT(*) AS total_shipments_dispatched
FROM SHIPMENT;

-- Q16: Count number of vehicles in the VEHICLE table
SELECT COUNT(*) AS total_fleet_vehicles
FROM VEHICLE;

-- Q17: Find the maximum salary among all drivers (oldest sailor)
SELECT MAX(salary) AS max_driver_salary
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%';

-- Q18: Find the minimum salary among all drivers (youngest sailor)
SELECT MIN(salary) AS min_driver_salary
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%';

-- Q19: Find the average salary of senior drivers (rating of 10)
SELECT ROUND(AVG(salary), 2) AS avg_senior_driver_salary
FROM EMPLOYEE
WHERE job_role LIKE '%Senior Fleet Driver%';

-- Q20: Count the number of distinct driver first names
SELECT COUNT(DISTINCT first_name) AS distinct_driver_names_count
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%';

-- Q21: Find the name and salary of the top-paid driver
SELECT first_name || ' ' || last_name AS driver_name, salary
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%'
ORDER BY salary DESC
LIMIT 1;

-- Q22: Count the total number of drivers
SELECT COUNT(*) AS driver_count
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%';

-- Q23: Find names of drivers hired earlier than the highest-paid driver
SELECT first_name || ' ' || last_name AS driver_name, hire_date, salary
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%'
  AND hire_date < (
      SELECT hire_date 
      FROM EMPLOYEE 
      WHERE job_role LIKE '%Driver%' 
      ORDER BY salary DESC 
      LIMIT 1
  );

-- Q24: Display all drivers sorted by hire date ascending
SELECT emp_id, first_name || ' ' || last_name AS driver_name, hire_date, salary
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%'
ORDER BY hire_date ASC;

-- Q25: Display names of all drivers in alphabetical order
SELECT first_name || ' ' || last_name AS driver_name, email, department_name
FROM EMPLOYEE
WHERE job_role LIKE '%Driver%'
ORDER BY driver_name ASC;
