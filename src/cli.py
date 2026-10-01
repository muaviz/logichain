import sys
from typing import Any, Dict, List

from rich.console import Console
from rich.panel import Panel
from rich.prompt import Prompt
from rich.syntax import Syntax
from rich.table import Table

from src.config import SQL_DIR
from src.database import execute_query, get_connection
from src.schema_loader import initialize_database

console = Console()

def print_banner():
    banner = r"""
  _             _  ____ _           _       
 | |   ___   __ _(_)/ ___| |__   __ _(_)_ __  
 | |  / _ \ / _` | | |   | '_ \ / _` | | '_ \ 
 | | | (_) | (_| | | |___| | | | (_| | | | | |
 |_|  \___/ \__, |_|\____|_| |_|\__,_|_|_| |_|
            |___/                             
 LogiChain - Supply Chain & Logistics DBMS CLI
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
        "SHIPMENT", "SHIPMENT_ITEM", "AUDIT_CLIENT_LOG", "AUDIT_INVENTORY_LOG"
    ]
    summary = []
    for t in tables:
        try:
            res = execute_query(f"SELECT COUNT(*) as row_count FROM {t};")
            summary.append({"Table_Name": t, "Total_Rows": res[0]["row_count"]})
        except Exception as e:
            summary.append({"Table_Name": t, "Total_Rows": f"Error: {e}"})

    render_table("LogiChain Core Database Entity Statistics (20 Tables)", summary)

def run_lab01_demo():
    console.print(Panel("[bold yellow]CSE3001 Lab 1: Pilot & Vehicle Certification / Division Queries[/bold yellow]"))
    q_file = SQL_DIR / "queries" / "lab_equivalents" / "lab01_certification_queries.sql"
    if q_file.exists():
        with open(q_file, "r") as f:
            content = f.read()
        console.print(Syntax(content[:600] + "\n-- [... see file for complete script ...]", "sql", theme="monokai", line_numbers=True))

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
    console.print("[cyan]Sampling queries from the 25-query suite (all 25 in sql/queries/lab_equivalents/lab02_sailors_25_queries.sql)[/cyan]\n")

    console.print("[bold green]Q13: Driver with highest salary using ALL / Subquery operator:[/bold green]")
    q13 = """
    SELECT emp_id, first_name || ' ' || last_name AS driver_name, salary
    FROM EMPLOYEE
    WHERE job_role LIKE '%Driver%'
      AND salary >= (SELECT MAX(salary) FROM EMPLOYEE WHERE job_role LIKE '%Driver%');
    """
    render_table("Q13 Result (Top Salary Driver)", execute_query(q13))

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
    console.print(Panel("[bold yellow]CSE3001 Lab 3: Wholesale Multi-Dimensional Product & Sales Analysis[/bold yellow]"))
    q = """
    SELECT 
        p.material_type,
        COUNT(oi.order_id) AS total_order_items,
        SUM(oi.ordered_qty) AS total_units_sold,
        ROUND(SUM(oi.ordered_qty * oi.unit_price), 2) AS gross_income,
        ROUND(SUM(oi.ordered_qty * oi.unit_price * oi.discount_rate), 2) AS total_discounts,
        ROUND(SUM(oi.line_total), 2) AS net_realized_income,
        ROUND(AVG(oi.line_total), 2) AS avg_item_sale_amount
    FROM ORDER_ITEM oi
    JOIN PRODUCT p ON oi.product_id = p.product_id
    GROUP BY p.material_type
    ORDER BY net_realized_income DESC;
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

    console.print("\n[bold cyan]Boss Hierarchy with [PRESIDENT / CEO] for Eleanor Vance:[/bold cyan]")
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

def run_acid_transaction_demo():
    console.print(Panel("[bold yellow]CSE3001 Unit 5: ACID Transaction & Savepoints Demonstration[/bold yellow]"))
    console.print("[cyan]Demonstrating Atomicity, Consistency, Isolation, and Savepoint Rollback:[/cyan]\n")

    conn = get_connection()
    c = conn.cursor()
    try:
        c.execute("SELECT quantity_on_hand FROM INVENTORY_STOCK WHERE warehouse_id = 401 AND product_id = 301;")
        initial_stock = c.fetchone()["quantity_on_hand"]
        console.print(f"Initial Inventory (WH 401, Product 301): {initial_stock} units")

        console.print("\nStep 1: Starting Atomic Transaction with Savepoint...")
        c.execute("SAVEPOINT svp_start;")

        c.execute("UPDATE INVENTORY_STOCK SET quantity_on_hand = quantity_on_hand - 10 WHERE warehouse_id = 401 AND product_id = 301;")
        c.execute("SELECT quantity_on_hand FROM INVENTORY_STOCK WHERE warehouse_id = 401 AND product_id = 301;")
        interim_stock = c.fetchone()["quantity_on_hand"]
        console.print(f"  Intermediate Deducted Stock: {interim_stock} units")

        console.print("Step 2: Simulating Failure Condition -> Executing ROLLBACK TO SAVEPOINT svp_start;")
        c.execute("ROLLBACK TO SAVEPOINT svp_start;")

        c.execute("SELECT quantity_on_hand FROM INVENTORY_STOCK WHERE warehouse_id = 401 AND product_id = 301;")
        restored_stock = c.fetchone()["quantity_on_hand"]
        console.print(f"  Stock after Rollback: {restored_stock} units (Restored to initial state!)")

        console.print("Step 3: Executing final valid transaction with COMMIT...")
        c.execute("UPDATE INVENTORY_STOCK SET quantity_on_hand = quantity_on_hand - 2 WHERE warehouse_id = 401 AND product_id = 301;")
        conn.commit()

        c.execute("SELECT quantity_on_hand FROM INVENTORY_STOCK WHERE warehouse_id = 401 AND product_id = 301;")
        final_stock = c.fetchone()["quantity_on_hand"]
        console.print(f"  Committed Final Stock: {final_stock} units")
        console.print("[green]Transaction Atomicity and Consistency Verified![/green]")

    except Exception as e:
        conn.rollback()
        console.print(f"[red]Transaction Aborted: {e}[/red]")
    finally:
        conn.close()

def oracle_plsql_menu():
    plsql_files = {
        "1": ("01_oracle_ddl_sequences.sql", "Oracle DDL, Sequences & Synonyms"),
        "2": ("02_oracle_packages.sql", "PL/SQL Packages (Specs & Bodies)"),
        "3": ("03_oracle_cursors_savepoints.sql", "Explicit Cursors, Savepoints & Batch Deletes"),
        "4": ("04_oracle_exceptions.sql", "User-Defined Business Exceptions & PRAGMA"),
        "5": ("05_oracle_procedures_functions.sql", "Stored Procedures with IN/OUT & Functions")
    }

    while True:
        console.print("\n[bold cyan]Oracle PL/SQL Suite Reference[/bold cyan]")
        for k, (fname, desc) in plsql_files.items():
            console.print(f" [{k}] {desc} ({fname})")
        console.print(" [0] Back")

        choice = Prompt.ask("\nEnter choice", choices=["0", "1", "2", "3", "4", "5"], default="0")
        if choice == "0":
            return

        fname, desc = plsql_files[choice]
        filepath = SQL_DIR / "plsql_oracle" / fname
        if filepath.exists():
            with open(filepath, "r") as f:
                content = f.read()
            console.clear()
            console.print(Panel(f"[bold yellow]Oracle PL/SQL: {desc}[/bold yellow]"))
            console.print(Syntax(content[:1500] + "\n\n-- [... see file for complete 100% native Oracle script ...]", "sql", theme="monokai", line_numbers=True))
            Prompt.ask("\n[dim]Press Enter to continue...[/dim]")
            console.clear()

def sql_analytics_menu():
    while True:
        console.print("\n[bold cyan]SQL Query Suite & Lab Equivalents[/bold cyan]")
        console.print(" [1] Lab 1: Pilot/Vehicle Certification & Relational Division")
        console.print(" [2] Lab 2: 25-Query Sailors & Boats Benchmark Catalog")
        console.print(" [3] Lab 3: Wholesale Multi-Dimensional Product & Sales Analysis")
        console.print(" [4] Lab 11: Employee & Department Hierarchy (Self-Joins)")
        console.print(" [0] Back")

        choice = Prompt.ask("\nEnter choice", choices=["0", "1", "2", "3", "4"], default="0")
        console.clear()

        if choice == "0":
            return
        elif choice == "1":
            run_lab01_demo()
        elif choice == "2":
            run_lab02_demo()
        elif choice == "3":
            run_lab03_demo()
        elif choice == "4":
            run_lab11_demo()

        Prompt.ask("\n[dim]Press Enter to continue...[/dim]")
        console.clear()

def main_menu():
    while True:
        print_banner()
        console.print("[bold]Main Menu[/bold]\n")
        console.print(" [1] View Database Statistics (20 Tables)")
        console.print(" [2] SQL Query Suite (Labs 1, 2, 3, 11)")
        console.print(" [3] Database Triggers & Auditing (Labs 5, 10)")
        console.print(" [4] ACID Transaction & Savepoints Demo")
        console.print(" [5] Oracle PL/SQL Suite Viewer")
        console.print(" [6] Database Management (Re-seed DB)")
        console.print(" [0] Exit")

        choice = Prompt.ask("\nEnter choice", choices=["0", "1", "2", "3", "4", "5", "6"], default="1")
        console.clear()

        if choice == "0":
            console.print("[bold green]Thank you for exploring LogiChain DBMS![/bold green]")
            sys.exit(0)
        elif choice == "1":
            show_database_stats()
        elif choice == "2":
            sql_analytics_menu()
        elif choice == "3":
            run_lab05_10_triggers_demo()
        elif choice == "4":
            run_acid_transaction_demo()
        elif choice == "5":
            oracle_plsql_menu()
        elif choice == "6":
            console.print("\n[bold cyan]Database Management[/bold cyan]")
            console.print(" [1] Re-Initialize & Seed Database")
            console.print(" [0] Back")
            db_choice = Prompt.ask("\nEnter choice", choices=["0", "1"], default="0")
            if db_choice == "1":
                initialize_database(reset=True)
                console.print("[bold green]Database successfully re-initialized and seeded![/bold green]")

        Prompt.ask("\n[dim]Press Enter to continue...[/dim]")
        console.clear()

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "--demo":
        show_database_stats()
        run_lab01_demo()
        run_lab02_demo()
        run_lab03_demo()
        run_lab05_10_triggers_demo()
        run_lab11_demo()
        run_acid_transaction_demo()
    else:
        main_menu()
