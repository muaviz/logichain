-- ============================================================================
-- LAB 1 EQUIVALENT: VEHICLE & DRIVER CERTIFICATION QUERIES
-- Maps to CSE3001 Lab 1 (Airlines / Aircraft / Pilot Certification)
-- ============================================================================

-- Query 1: Find the employee IDs (eids) of drivers/pilots certified for Boeing heavy air freighters
SELECT dc.emp_id
FROM DRIVER_CERTIFICATION dc
JOIN VEHICLE_TYPE vt ON dc.type_code = vt.type_code
WHERE vt.type_name LIKE '%Boeing%';

-- Query 2: Find the names of drivers/pilots certified for Boeing aircraft
SELECT e.first_name || ' ' || e.last_name AS pilot_name
FROM EMPLOYEE e
JOIN DRIVER_CERTIFICATION dc ON e.emp_id = dc.emp_id
JOIN VEHICLE_TYPE vt ON dc.type_code = vt.type_code
WHERE vt.type_name LIKE '%Boeing%';

-- Query 3: Find the vehicle IDs of all vehicles that can be used on routes requiring > 1,500 km range
-- (Equivalent to non-stop flights from Bonn to Madras)
SELECT v.vehicle_id, v.license_plate, vt.type_name, vt.cruising_range_km
FROM VEHICLE v
JOIN VEHICLE_TYPE vt ON v.type_code = vt.type_code
WHERE vt.cruising_range_km >= 1500;

-- Query 4: Relational Division - Identify the vehicle types that can be operated by EVERY driver whose salary > $70,000
SELECT vt.type_code, vt.type_name
FROM VEHICLE_TYPE vt
WHERE NOT EXISTS (
    SELECT e.emp_id
    FROM EMPLOYEE e
    WHERE e.salary > 70000 AND e.job_role LIKE '%Driver%'
      AND NOT EXISTS (
          SELECT 1
          FROM DRIVER_CERTIFICATION dc
          WHERE dc.emp_id = e.emp_id
            AND dc.type_code = vt.type_code
      )
);

-- Query 5: Find the names of drivers who can operate vehicles with range > 1,000 km but are NOT certified on any Boeing aircraft
SELECT DISTINCT e.first_name || ' ' || e.last_name AS driver_name
FROM EMPLOYEE e
JOIN DRIVER_CERTIFICATION dc ON e.emp_id = dc.emp_id
JOIN VEHICLE_TYPE vt ON dc.type_code = vt.type_code
WHERE vt.cruising_range_km > 1000
  AND e.emp_id NOT IN (
      SELECT dc2.emp_id
      FROM DRIVER_CERTIFICATION dc2
      JOIN VEHICLE_TYPE vt2 ON dc2.type_code = vt2.type_code
      WHERE vt2.type_name LIKE '%Boeing%'
  );
