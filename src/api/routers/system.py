import time
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Dict, Any, Optional
from src.database import get_connection, execute_query
from src.simulations.isolation_runner import IsolationLevelSimulator
from src.simulations.deadlock_runner import DeadlockSimulator
from src.simulations.two_phase_commit import TwoPhaseCommitSimulator
from src.config import SQL_DIR

router = APIRouter(prefix="/system", tags=["System & GUI Controls"])

class SQLQueryRequest(BaseModel):
    query: str

class TwoPCRequest(BaseModel):
    tx_id: str = "TX-DISPATCH-2026-99"
    simulate_failure_node: Optional[str] = None

@router.get("/tables")
def get_all_tables_info() -> List[Dict[str, Any]]:
    """Returns all table names, columns, and row counts for the GUI Table Explorer."""
    conn = get_connection()
    try:
        c = conn.cursor()
        c.execute("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name;")
        table_names = [row["name"] for row in c.fetchall()]

        table_info = []
        for tbl in table_names:
            c.execute(f"SELECT COUNT(*) as count FROM {tbl};")
            count = c.fetchone()["count"]

            c.execute(f"PRAGMA table_info({tbl});")
            cols = [col["name"] for col in c.fetchall()]

            table_info.append({
                "table_name": tbl,
                "row_count": count,
                "columns": cols
            })
        return table_info
    finally:
        conn.close()

@router.get("/tables/{table_name}")
def get_table_data(table_name: str, limit: int = 100) -> Dict[str, Any]:
    """Returns row data and columns for a given table."""
    conn = get_connection()
    try:
        c = conn.cursor()
        # Validate table name against sqlite_master to prevent SQL injection
        c.execute("SELECT name FROM sqlite_master WHERE type IN ('table', 'view') AND name = ?;", (table_name,))
        if not c.fetchone():
            raise HTTPException(status_code=404, detail=f"Table or view '{table_name}' does not exist.")

        c.execute(f"SELECT * FROM {table_name} LIMIT ?;", (limit,))
        rows = [dict(r) for r in c.fetchall()]
        columns = list(rows[0].keys()) if rows else []

        return {
            "table_name": table_name,
            "columns": columns,
            "rows": rows,
            "total_fetched": len(rows)
        }
    finally:
        conn.close()

@router.post("/query")
def execute_custom_query(req: SQLQueryRequest) -> Dict[str, Any]:
    """Executes a custom SQL query from the GUI console and returns execution metrics."""
    query = req.query.strip()
    if not query:
        raise HTTPException(status_code=400, detail="Query cannot be empty.")

    conn = get_connection()
    start_time = time.perf_counter()
    try:
        c = conn.cursor()
        c.execute(query)
        duration_ms = round((time.perf_counter() - start_time) * 1000, 2)

        if query.upper().startswith("SELECT") or query.upper().startswith("WITH") or query.upper().startswith("PRAGMA") or query.upper().startswith("EXPLAIN"):
            rows = [dict(r) for r in c.fetchall()]
            columns = list(rows[0].keys()) if rows else []
            return {
                "status": "SUCCESS",
                "type": "DQL",
                "execution_time_ms": duration_ms,
                "columns": columns,
                "rows": rows,
                "row_count": len(rows)
            }
        else:
            conn.commit()
            return {
                "status": "SUCCESS",
                "type": "DML",
                "execution_time_ms": duration_ms,
                "rows_affected": c.rowcount
            }
    except Exception as e:
        conn.rollback()
        duration_ms = round((time.perf_counter() - start_time) * 1000, 2)
        return {
            "status": "ERROR",
            "execution_time_ms": duration_ms,
            "error_message": str(e)
        }
    finally:
        conn.close()

@router.post("/simulations/isolation")
def run_isolation_simulation() -> Dict[str, Any]:
    """Runs the ACID isolation anomaly simulation."""
    sim = IsolationLevelSimulator()
    return sim.demonstrate_non_repeatable_read()

@router.post("/simulations/deadlock")
def run_deadlock_simulation() -> Dict[str, Any]:
    """Runs the deadlock detection simulation."""
    sim = DeadlockSimulator()
    return sim.run_competing_transactions()

@router.post("/simulations/2pc")
def run_2pc_simulation(req: TwoPCRequest) -> Dict[str, Any]:
    """Runs the Distributed Two-Phase Commit simulation."""
    sim = TwoPhaseCommitSimulator()
    return sim.execute_2pc_transaction(req.tx_id, simulate_failure_node=req.simulate_failure_node)

@router.get("/labs/{lab_id}")
def get_lab_suite(lab_id: str) -> Dict[str, Any]:
    """Executes preset lab queries and returns SQL text and tabular results."""
    if lab_id == "lab01":
        sql_file = SQL_DIR / "queries" / "lab_equivalents" / "lab01_certification_queries.sql"
        q1 = """
        SELECT e.emp_id, e.first_name || ' ' || e.last_name AS pilot_name, vt.type_name, dc.certification_number
        FROM EMPLOYEE e
        JOIN DRIVER_CERTIFICATION dc ON e.emp_id = dc.emp_id
        JOIN VEHICLE_TYPE vt ON dc.type_code = vt.type_code
        WHERE vt.type_name LIKE '%Boeing%';
        """
        q2 = """
        SELECT vt.type_code, vt.type_name, vt.max_payload_kg
        FROM VEHICLE_TYPE vt
        WHERE NOT EXISTS (
            SELECT e.emp_id
            FROM EMPLOYEE e
            WHERE e.salary > 70000 AND e.job_role LIKE '%Driver%'
              AND NOT EXISTS (
                  SELECT 1
                  FROM DRIVER_CERTIFICATION dc
                  WHERE dc.emp_id = e.emp_id AND dc.type_code = vt.type_code
              )
        );
        """
        return {
            "lab_title": "Lab 1: Pilot & Vehicle Certification / Relational Division",
            "sql_content": sql_file.read_text(encoding="utf-8"),
            "sections": [
                {"title": "Boeing Certified Pilots", "data": execute_query(q1)},
                {"title": "Relational Division (Vehicle Types Qualified by All Senior Drivers)", "data": execute_query(q2)}
            ]
        }
    elif lab_id == "lab02":
        sql_file = SQL_DIR / "queries" / "lab_equivalents" / "lab02_sailors_25_queries.sql"
        q13 = """
        SELECT emp_id, first_name || ' ' || last_name AS driver_name, salary
        FROM EMPLOYEE
        WHERE job_role LIKE '%Driver%'
          AND salary >= (SELECT MAX(salary) FROM EMPLOYEE WHERE job_role LIKE '%Driver%');
        """
        q7 = """
        SELECT DISTINCT e.first_name || ' ' || e.last_name AS driver_name, vt.type_name, v.license_plate
        FROM EMPLOYEE e
        JOIN SHIPMENT s ON e.emp_id = s.driver_id
        JOIN VEHICLE v ON s.vehicle_id = v.vehicle_id
        JOIN VEHICLE_TYPE vt ON v.type_code = vt.type_code
        WHERE e.first_name = 'Rajesh';
        """
        return {
            "lab_title": "Lab 2: Sailors & Fleet 25 Benchmark Queries Catalog",
            "sql_content": sql_file.read_text(encoding="utf-8"),
            "sections": [
                {"title": "Q13: Top Paid Driver (ALL Operator Equivalent)", "data": execute_query(q13)},
                {"title": "Q7: Vehicles Dispatched by Rajesh", "data": execute_query(q7)}
            ]
        }
    elif lab_id == "lab03":
        sql_file = SQL_DIR / "queries" / "lab_equivalents" / "lab03_dimensional_olap.sql"
        q = """
        SELECT 
            dp.material_type,
            COUNT(f.fact_sales_id) AS total_orders,
            SUM(f.quantity_sold) AS total_quantity_sold,
            ROUND(SUM(f.gross_revenue), 2) AS gross_revenue,
            ROUND(SUM(f.discount_amount), 2) AS total_discounts,
            ROUND(SUM(f.net_revenue), 2) AS net_revenue,
            ROUND(AVG(f.profit_margin), 2) AS avg_profit_margin
        FROM FACT_SALES_SHIPMENT f
        JOIN DIM_PRODUCT_HIERARCHY dp ON f.dim_product_key = dp.dim_product_key
        GROUP BY dp.material_type
        ORDER BY net_revenue DESC;
        """
        return {
            "lab_title": "Lab 3: Wholesale Multi-Dimensional OLAP & Star Schema",
            "sql_content": sql_file.read_text(encoding="utf-8"),
            "sections": [
                {"title": "Wholesale Sales by Material Type", "data": execute_query(q)}
            ]
        }
    elif lab_id == "lab11":
        sql_file = SQL_DIR / "queries" / "lab_equivalents" / "lab11_employee_hierarchy.sql"
        q = """
        SELECT 
            m.emp_id AS manager_emp_id,
            m.first_name || ' ' || m.last_name AS manager_name,
            m.job_role,
            COUNT(e.emp_id) AS employees_managed_count
        FROM EMPLOYEE m
        JOIN EMPLOYEE e ON e.manager_id = m.emp_id
        GROUP BY m.emp_id, m.first_name, m.last_name, m.job_role
        ORDER BY employees_managed_count DESC;
        """
        return {
            "lab_title": "Lab 11: Employee & Department Hierarchy / Self-Joins",
            "sql_content": sql_file.read_text(encoding="utf-8"),
            "sections": [
                {"title": "Manager Subordinate Rankings", "data": execute_query(q)}
            ]
        }
    else:
        raise HTTPException(status_code=404, detail="Lab ID not found.")
