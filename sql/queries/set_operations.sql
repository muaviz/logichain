-- ============================================================================
-- SET OPERATORS: UNION, UNION ALL, INTERSECT, EXCEPT / MINUS
-- Maps to CSE3001 Unit 2 & Unit 3 (Relational Algebra Set Operators)
-- ============================================================================

-- 1. UNION: All cities where LogiChain has either a Warehouse, a Customer, or a Supplier
SELECT city, state, 'WAREHOUSE HUB' AS entity_type
FROM GEOGRAPHY_LOCATION
WHERE loc_id IN (SELECT loc_id FROM WAREHOUSE)
UNION
SELECT city, state, 'CUSTOMER CLIENT' AS entity_type
FROM GEOGRAPHY_LOCATION
WHERE loc_id IN (SELECT loc_id FROM CUSTOMER)
UNION
SELECT city, state, 'SUPPLIER VENDOR' AS entity_type
FROM GEOGRAPHY_LOCATION
WHERE loc_id IN (SELECT loc_id FROM SUPPLIER)
ORDER BY city;

-- 2. INTERSECT: Cities where BOTH a Warehouse AND a Customer exist
SELECT g.city, g.state
FROM GEOGRAPHY_LOCATION g
WHERE g.loc_id IN (SELECT loc_id FROM WAREHOUSE)
INTERSECT
SELECT g.city, g.state
FROM GEOGRAPHY_LOCATION g
WHERE g.loc_id IN (SELECT loc_id FROM CUSTOMER);

-- 3. EXCEPT / MINUS: Cities where Suppliers exist but NO Warehouse Hub exists
SELECT g.city, g.state
FROM GEOGRAPHY_LOCATION g
WHERE g.loc_id IN (SELECT loc_id FROM SUPPLIER)
EXCEPT
SELECT g.city, g.state
FROM GEOGRAPHY_LOCATION g
WHERE g.loc_id IN (SELECT loc_id FROM WAREHOUSE);
