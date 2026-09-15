import sqlite3
import contextlib
from typing import Generator, List, Dict, Any, Optional
from src.config import SQLITE_DB_PATH

def get_connection(timeout: float = 10.0) -> sqlite3.Connection:
    """Returns a new SQLite connection with foreign keys and dict row factory enabled."""
    conn = sqlite3.connect(str(SQLITE_DB_PATH), timeout=timeout)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON;")
    return conn

@contextlib.contextmanager
def get_db_cursor() -> Generator[sqlite3.Cursor, None, None]:
    """Context manager for obtaining a database cursor with automatic commit/rollback."""
    conn = get_connection()
    cursor = conn.cursor()
    try:
        yield cursor
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        cursor.close()
        conn.close()

def execute_query(query: str, params: tuple = ()) -> List[Dict[str, Any]]:
    """Executes a SELECT query and returns a list of dictionaries."""
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(query, params)
        rows = cursor.fetchall()
        return [dict(row) for row in rows]
    finally:
        conn.close()

def execute_statement(statement: str, params: tuple = ()) -> int:
    """Executes an INSERT/UPDATE/DELETE statement and returns rows affected."""
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(statement, params)
        conn.commit()
        return cursor.rowcount
    finally:
        conn.close()
