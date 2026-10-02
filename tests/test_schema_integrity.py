import sqlite3

import pytest

from src.database import get_connection
from src.schema_loader import initialize_database


@pytest.fixture(autouse=True)
def setup_db():
    initialize_database(reset=True)

def test_primary_key_uniqueness():
    conn = get_connection()
    c = conn.cursor()
    # Try inserting duplicate PK
    with pytest.raises(sqlite3.IntegrityError):
        c.execute("""
            INSERT INTO GEOGRAPHY_LOCATION (loc_id, city, region, state, country, postal_code)
            VALUES (101, 'Duplicate City', 'Northeast', 'NY', 'USA', '10001');
        """)
    conn.close()

def test_foreign_key_enforcement():
    conn = get_connection()
    c = conn.cursor()
    # Try inserting product with non-existent category_id
    with pytest.raises(sqlite3.IntegrityError):
        c.execute("""
            INSERT INTO PRODUCT (product_id, sku, product_name, category_id, material_type, unit_weight_kg, base_price)
            VALUES (9999, 'INVALID-SKU', 'Invalid Product', 999999, 'Steel', 10.0, 100.00);
        """)
    conn.close()

def test_check_constraints():
    conn = get_connection()
    c = conn.cursor()
    # Salary must be > 0
    with pytest.raises(sqlite3.IntegrityError):
        c.execute("""
            INSERT INTO EMPLOYEE (emp_id, first_name, last_name, email, hire_date, job_role, department_name, salary)
            VALUES (999, 'Bad', 'Salary', 'bad.salary@test.com', '2026-01-01', 'Clerk', 'Operations', -500.00);
        """)
    conn.close()

def test_weak_entity_cascade_deletion():
    conn = get_connection()
    c = conn.cursor()
    # Deleting an Employee should cascade delete their dependents
    c.execute("SELECT COUNT(*) FROM EMPLOYEE_DEPENDENT WHERE emp_id = 1;")
    assert c.fetchone()[0] > 0

    c.execute("DELETE FROM EMPLOYEE WHERE emp_id = 1;")
    conn.commit()

    c.execute("SELECT COUNT(*) FROM EMPLOYEE_DEPENDENT WHERE emp_id = 1;")
    assert c.fetchone()[0] == 0
    conn.close()
