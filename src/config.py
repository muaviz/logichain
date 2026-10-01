import os
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
SQL_DIR = BASE_DIR / "sql"
DOCS_DIR = BASE_DIR / "docs"

DB_TYPE = os.getenv("DB_TYPE", "sqlite")
SQLITE_DB_PATH = BASE_DIR / os.getenv("SQLITE_DB_PATH", "logichain.db")
