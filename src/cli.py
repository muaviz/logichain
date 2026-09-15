import sys
import os
from typing import List, Dict, Any
from rich.console import Console
from rich.table import Table
from rich.panel import Panel
from rich.prompt import Prompt
from rich.syntax import Syntax

from src.database import get_connection, execute_query
from src.schema_loader import initialize_database
from src.simulations.isolation_runner import IsolationLevelSimulator
from src.simulations.deadlock_runner import DeadlockSimulator
from src.simulations.two_phase_commit import TwoPhaseCommitSimulator
from src.config import SQL_DIR

console = Console()

def print_banner():
    banner = """
  _             _  ____ _           _       
 | |   ___   __ _(_)/ ___| |__   __ _(_)_ __  
 | |  / _ \ / _` | | |   | '_ \ / _` | | '_ \ 
 | | | (_) | (_| | | |___| | | | (_| | | | | |
 |_|  \___/ \__, |_|\____|_| |_|\__,_|_|_| |_|
            |___/                             
  Enterprise Supply Chain & Logistics DBMS Suite
  CSE3001 Complete Syllabus Reference System
    """
    console.print(f"[bold cyan]{banner}[/bold cyan]")

def render_table(title: str, rows: List[Dict[str, Any]]):
    if not rows:
        console.print(f"[yellow]No records found for '{title}'.[/yellow]")
        return

    table = Table(title=f"[bold green]{title}[/bold green]", show_header=True, header_style="bold magenta")
    headers = list(rows[0].keys())
    for h in headers:
        table.add_column(h.replace("_", " ").title())

    for r in rows:
        table.add_row(*[str(r[h]) if r[h] is not None else "[dim]NULL[/dim]" for h in headers])

    console.print(table)

def show_database_stats():
    tables = [
        "GEOGRAPHY_LOCATION", "EMPLOYEE", "EMPLOYEE_DEPENDENT", "SUPPLIER",
        "PRODUCT_CATEGORY", "PRODUCT", "SUPPLIER_PRODUCT", "WAREHOUSE",
        "WAREHOUSE_BIN", "INVENTORY_STOCK", "VEHICLE_TYPE", "VEHICLE",
        "DRIVER_CERTIFICATION", "CUSTOMER", "CUSTOMER_ORDER", "ORDER_ITEM",
        "SHIPMENT", "SHIPMENT_ITEM", "AUDIT_CLIENT_LOG", "AUDIT_INVENTORY_LOG",
        "FACT_SALES_SHIPMENT"
    ]
    summary = []
    for t in tables:
        try:
            res = execute_query(f"SELECT COUNT(*) as row_count FROM {t};")
            summary.append({"Table_Name": t, "Total_Rows": res[0]["row_count"]})
        except Exception as e:
            summary.append({"Table_Name": t, "Total_Rows": f"Error: {e}"})

    render_table("LogiChain Core Database Entity Statistics", summary)

def run_lab01_demo():
    console.print(Panel("[bold yellow]CSE3001 Lab 1: Pilot & Vehicle Certification / Division Queries[/bold yellow]"))
    q_file = SQL_DIR / "queries" / "lab_equivalents" / "lab01_certification_queries.sql"
    with open(q_file, "r") as f:
        content = f.read()
    console.print(Syntax(content, "sql", theme="monokai", line_numbers=True))

    console.print("\n[bold cyan]1. Pilots/Drivers certified for Boeing Air Freighters:[/bold cyan]")
    q1 = """
    SELECT e.emp_id, e.first_name || ' ' || e.last_name AS pilot_name, vt.type_name, dc.certification_number
    FROM EMPLOYEE e
    JOIN DRIVER_CERTIFICATION dc ON e.emp_id = dc.emp_id
    JOIN VEHICLE_TYPE vt ON dc.type_code = vt.type_code
    WHERE vt.type_name LIKE '%Boeing%';
    """
    render_table("Boeing Certified Pilots", execute_query(q1))

    console.print("\n[bold cyan]2. Relational Division: Vehicle Types qualified by EVERY Driver earning > $70k:[/bold cyan]")
    q4 = """
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
    render_table("Division Result: Vehicle Types Qualified by All Senior Drivers", execute_query(q4))

def run_lab02_demo():
    console.print(Panel("[bold yellow]CSE3001 Lab 2: 25-Query Sailors & Boats Benchmark Catalog[/bold yellow]"))
    console.print("[cyan]Sampling queries from the 25-query suite (all 25 available in sql/queries/lab_equivalents/lab02_sailors_25_queries.sql)[/cyan]\n")

    console.print("[bold green]Q13: Driver with highest salary using ALL operator (Standard SQL: '>= ALL', SQLite: '>= (SELECT MAX...)'):[/bold green]")
    q13 = """
    SELECT emp_id, first_name || ' ' || last_name AS driver_name, salary
    FROM EMPLOYEE
    WHERE job_role LIKE '%Driver%'
      AND salary >= (SELECT MAX(salary) FROM EMPLOYEE WHERE job_role LIKE '%Driver%');
    """
    render_table("Q13 Result (ALL Operator)", execute_query(q13))

    console.print("\n[bold green]Q7: Vehicles & Types driven by Rajesh:[/bold green]")
    q7 = """
    SELECT DISTINCT e.first_name || ' ' || e.last_name AS driver_name, vt.type_name, v.license_plate
    FROM EMPLOYEE e
    JOIN SHIPMENT s ON e.emp_id = s.driver_id
    JOIN VEHICLE v ON s.vehicle_id = v.vehicle_id
    JOIN VEHICLE_TYPE vt ON v.type_code = vt.type_code
    WHERE e.first_name = 'Rajesh';
    """
    render_table("Q7 Result (Rajesh's Dispatches)", execute_query(q7))

def run_lab03_demo():
    console.print(Panel("[bold yellow]CSE3001 Lab 3: Wholesale Multi-Dimensional OLAP Analysis (Star Schema)[/bold yellow]"))
    q = """
    SELECT 
        dp.material_type,
        COUNT(f.fact_sales_id) AS orders_count,
        SUM(f.quantity_sold) AS units_sold,
        ROUND(SUM(f.gross_revenue), 2) AS gross_income,
        ROUND(SUM(f.discount_amount), 2) AS discounts,
        ROUND(SUM(f.net_revenue), 2) AS net_revenue,
        ROUND(AVG(f.profit_margin), 2) AS avg_profit
    FROM FACT_SALES_SHIPMENT f
    JOIN DIM_PRODUCT_HIERARCHY dp ON f.dim_product_key = dp.dim_product_key
    GROUP BY dp.material_type
    ORDER BY net_revenue DESC;
    """
    render_table("Material-Wise Wholesale Financial Performance", execute_query(q))

def run_lab05_10_triggers_demo():
    console.print(Panel("[bold yellow]CSE3001 Lab 5 & Lab 10: Triggers & Transparent Auditing[/bold yellow]"))

    console.print("\n[bold cyan]1. Demonstrating Lab 5: Transparent Audit on Customer Balance Update[/bold cyan]")
    conn = get_connection()
    c = conn.cursor()
    c.execute("SELECT customer_id, company_name, balance_due FROM CUSTOMER WHERE customer_id = 701;")
    c_before = c.fetchone()
    console.print(f"Customer 701 Balance BEFORE Update: ${c_before['balance_due']:,.2f}")

    # Perform update
    new_bal = c_before["balance_due"] + 1500.00
    c.execute("UPDATE CUSTOMER SET balance_due = ? WHERE customer_id = 701;", (new_bal,))
    conn.commit()

    c.execute("SELECT * FROM AUDIT_CLIENT_LOG WHERE customer_id = 701 ORDER BY audit_id DESC LIMIT 1;")
    audit_entry = c.fetchone()
    console.print(f"[green]Audit Trigger Automatically Captured Action:[/green] Operation={audit_entry['operation']}, Old Balance=${audit_entry['old_balance_due']:,.2f}, New Balance=${audit_entry['new_balance_due']:,.2f}, User={audit_entry['db_user']}")

    console.print("\n[bold cyan]2. Demonstrating Lab 10: User-Defined Error Trigger (Blocking illegal price reduction > 75%)[/bold cyan]")
    try:
        c.execute("UPDATE PRODUCT SET base_price = 10.00 WHERE product_id = 301;")
        conn.commit()
    except Exception as e:
        console.print(f"[bold red]Trigger Successfully Blocked Illegal DML:[/bold red] {e}")
    finally:
        conn.close()

def run_lab11_demo():
    console.print(Panel("[bold yellow]CSE3001 Lab 11: Employee & Department Hierarchy / Self-Joins[/bold yellow]"))
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
    render_table("Manager Subordinate Rankings", execute_query(q))

    console.print("\n[bold cyan]Boss Hierarchy with BLANK for CEO Eleanor Vance:[/bold cyan]")
    q_boss = """
    SELECT 
        e.first_name || ' ' || e.last_name AS employee_name,
        COALESCE(m.first_name || ' ' || m.last_name, '[PRESIDENT / CEO]') AS boss_name,
        e.department_name
    FROM EMPLOYEE e
    LEFT JOIN EMPLOYEE m ON e.manager_id = m.emp_id
    LIMIT 10;
    """
    render_table("Employee-Boss Hierarchy", execute_query(q_boss))

def run_concurrency_demo():
    console.print(Panel("[bold yellow]CSE3001 Unit 5: Concurrency Control & Isolation Anomalies Simulation[/bold yellow]"))
    sim = IsolationLevelSimulator()
    res = sim.demonstrate_non_repeatable_read()
    for line in res["execution_trace"]:
        console.print(f"  [cyan]{line}[/cyan]")
    console.print(f"\n[green]{res['conclusion']}[/green]")

def run_deadlock_demo():
    console.print(Panel("[bold yellow]CSE3001 Unit 5: Deadlock Detection & Wait-For Graph Simulator[/bold yellow]"))
    sim = DeadlockSimulator()
    res = sim.run_competing_transactions()
    for l in res["logs"]:
        console.print(f"  {l}")
    console.print(f"\n[green]Resolution:[/green] {res['resolution_technique']}")

def run_2pc_demo():
    console.print(Panel("[bold yellow]CSE3001 Unit 5: Distributed Two-Phase Commit (2PC) Protocol[/bold yellow]"))
    sim = TwoPhaseCommitSimulator()
    res = sim.execute_2pc_transaction("TX-LOGICHAIN-DISPATCH-88", simulate_failure_node="DEPOT-CHI-403")
    for l in res["execution_log"]:
        console.print(f"  {l}")

def main_menu():
    while True:
        print_banner()
        console.print("[bold]Select an Option:[/bold]")
        console.print("  [1] View Database Schema & Statistics")
        console.print("  [2] Run Lab 1: Pilot/Vehicle Certification & Division Queries")
        console.print("  [3] Run Lab 2: 25-Query Sailors & Fleet Benchmark Catalog")
        console.print("  [4] Run Lab 3: Wholesale Multi-Dimensional OLAP (Star Schema)")
        console.print("  [5] Run Lab 5 & 10: Transparent Audit & Error Trigger Demos")
        console.print("  [6] Run Lab 11: Employee Hierarchy & Boss Self-Joins")
        console.print("  [7] Run Concurrency & Isolation Anomaly Simulation (Unit 5)")
        console.print("  [8] Run Deadlock & Wait-For Graph Simulator (Unit 5)")
        console.print("  [9] Run Distributed Two-Phase Commit (2PC) Simulator (Unit 5)")
        console.print("  [10] Re-Initialize & Seed Database")
        console.print("  [0] Exit")

        choice = Prompt.ask("\nEnter choice", choices=["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10"], default="1")
        console.clear()

        if choice == "0":
            console.print("[bold green]Thank you for exploring LogiChain DBMS![/bold green]")
            sys.exit(0)
        elif choice == "1":
            show_database_stats()
        elif choice == "2":
            run_lab01_demo()
        elif choice == "3":
            run_lab02_demo()
        elif choice == "4":
            run_lab03_demo()
        elif choice == "5":
            run_lab05_10_triggers_demo()
        elif choice == "6":
            run_lab11_demo()
        elif choice == "7":
            run_concurrency_demo()
        elif choice == "8":
            run_deadlock_demo()
        elif choice == "9":
            run_2pc_demo()
        elif choice == "10":
            initialize_database(reset=True)
            console.print("[bold green]Database successfully re-initialized and seeded![/bold green]")

        Prompt.ask("\n[dim]Press Enter to continue...[/dim]")
        console.clear()

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--demo":
        show_database_stats()
        run_lab01_demo()
        run_lab05_10_triggers_demo()
        run_concurrency_demo()
    else:
        main_menu()
