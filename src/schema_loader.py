import os
import sqlite3
from pathlib import Path
from src.config import SQL_DIR, SQLITE_DB_PATH
from src.database import get_connection

def initialize_database(reset: bool = True) -> bool:
    """Initializes the database by executing all standard DDL, seed data, views, indexes, and triggers."""
    if reset and SQLITE_DB_PATH.exists():
        try:
            os.remove(SQLITE_DB_PATH)
        except OSError:
            pass

    conn = get_connection()
    cursor = conn.cursor()

    sql_files = [
        SQL_DIR / "schema" / "01_ddl_tables.sql",
        SQL_DIR / "schema" / "02_seed_data.sql",
        SQL_DIR / "views" / "01_updatable_views.sql",
        SQL_DIR / "views" / "02_security_views.sql",
        SQL_DIR / "views" / "03_materialized_views.sql",
        SQL_DIR / "indexes" / "01_performance_indexes.sql",
        SQL_DIR / "triggers" / "01_audit_triggers.sql",
        SQL_DIR / "triggers" / "02_business_rule_triggers.sql",
        SQL_DIR / "triggers" / "03_inventory_sync_triggers.sql",
    ]

    for file_path in sql_files:
        if file_path.exists():
            with open(file_path, "r", encoding="utf-8") as f:
                script = f.read()
                cursor.executescript(script)

    conn.commit()
    conn.close()
    return True

if __name__ == "__main__":
    print("Initializing LogiChain Database...")
    initialize_database()
    print("Database successfully initialized and seeded!")
