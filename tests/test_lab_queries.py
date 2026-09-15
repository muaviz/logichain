import pytest
from src.schema_loader import initialize_database
from src.database import execute_query

@pytest.fixture(autouse=True)
def setup_db():
    initialize_database(reset=True)

def test_lab01_boeing_pilots():
    q = """
    SELECT e.first_name || ' ' || e.last_name AS pilot_name
    FROM EMPLOYEE e
    JOIN DRIVER_CERTIFICATION dc ON e.emp_id = dc.emp_id
    JOIN VEHICLE_TYPE vt ON dc.type_code = vt.type_code
    WHERE vt.type_name LIKE '%Boeing%';
    """
    res = execute_query(q)
    assert len(res) >= 1
    assert "Rajesh Kumar" in [r["pilot_name"] for r in res]

def test_lab02_sailors_25_queries():
    # Test Q13 ALL operator equivalent
    q13 = """
    SELECT emp_id, salary
    FROM EMPLOYEE
    WHERE job_role LIKE '%Driver%'
      AND salary >= (SELECT MAX(salary) FROM EMPLOYEE WHERE job_role LIKE '%Driver%');
    """
    res13 = execute_query(q13)
    assert len(res13) == 1
    assert res13[0]["emp_id"] == 8

    # Test Q22 Count
    q22 = "SELECT COUNT(*) as cnt FROM EMPLOYEE WHERE job_role LIKE '%Driver%';"
    res22 = execute_query(q22)
    assert res22[0]["cnt"] == 4

def test_lab03_dimensional_olap():
    q = """
    SELECT dp.material_type, SUM(f.net_revenue) as net_rev
    FROM FACT_SALES_SHIPMENT f
    JOIN DIM_PRODUCT_HIERARCHY dp ON f.dim_product_key = dp.dim_product_key
    GROUP BY dp.material_type;
    """
    res = execute_query(q)
    assert len(res) >= 3
    assert any(r["material_type"] == "Wood" for r in res)

def test_lab11_hierarchy_queries():
    # President Eleanor Vance has no manager
    q = "SELECT first_name, last_name FROM EMPLOYEE WHERE manager_id IS NULL;"
    res = execute_query(q)
    assert len(res) == 1
    assert res[0]["first_name"] == "Eleanor"
