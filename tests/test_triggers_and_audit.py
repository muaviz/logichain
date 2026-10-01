import sqlite3

import pytest

from src.database import get_connection
from src.schema_loader import initialize_database


@pytest.fixture(autouse=True)
def setup_db():
    initialize_database(reset=True)

def test_transparent_audit_trigger():
    conn = get_connection()
    c = conn.cursor()

    # Update customer balance
    c.execute("UPDATE CUSTOMER SET balance_due = 15000.00 WHERE customer_id = 701;")
    conn.commit()

    c.execute("SELECT * FROM AUDIT_CLIENT_LOG WHERE customer_id = 701 AND operation = 'UPDATE' ORDER BY audit_id DESC LIMIT 1;")
    row = c.fetchone()
    assert row is not None
    assert row["old_balance_due"] == 12500.00
    assert row["new_balance_due"] == 15000.00
    assert row["db_user"] == "APP_TRIGGER_AUDITOR"
    conn.close()

def test_user_defined_error_trigger():
    conn = get_connection()
    c = conn.cursor()

    # Price drop > 75% should raise user-defined exception
    with pytest.raises(sqlite3.IntegrityError) as exc_info:
        c.execute("UPDATE PRODUCT SET base_price = 5.00 WHERE product_id = 301;")
    
    assert "ERR-30012" in str(exc_info.value)
    conn.close()
