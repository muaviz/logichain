import time
import threading
import sqlite3
from typing import Dict, Any, List
from src.config import SQLITE_DB_PATH
from src.database import get_connection

class IsolationLevelSimulator:
    """Simulates and explains ACID Transaction Isolation Levels and Anomalies.
    Maps to CSE3001 Unit 5 (Transaction Management & Concurrency Control).
    """

    @staticmethod
    def demonstrate_dirty_read_concept() -> Dict[str, Any]:
        """Explains Dirty Read: T1 updates data without committing; T2 reads uncommitted data; T1 rolls back."""
        return {
            "anomaly": "Dirty Read (G1)",
            "definition": "A transaction reads data written by a concurrent uncommitted transaction.",
            "allowed_in": ["READ UNCOMMITTED"],
            "prevented_in": ["READ COMMITTED", "REPEATABLE READ", "SERIALIZABLE"],
            "scenario": [
                "1. T1: BEGIN TRANSACTION;",
                "2. T1: UPDATE INVENTORY_STOCK SET quantity_on_hand = 999 WHERE product_id = 301; (Not Committed)",
                "3. T2: SELECT quantity_on_hand FROM INVENTORY_STOCK WHERE product_id = 301; -> Sees 999 (Dirty!)",
                "4. T1: ROLLBACK; (Stock reverts to 150)",
                "5. Consequence: T2 made decisions based on data that never officially existed."
            ]
        }

    @staticmethod
    def demonstrate_non_repeatable_read() -> Dict[str, Any]:
        """Demonstrates Non-Repeatable Read: T1 reads a row; T2 modifies that row & commits; T1 re-reads and gets different value."""
        conn1 = sqlite3.connect(str(SQLITE_DB_PATH))
        conn2 = sqlite3.connect(str(SQLITE_DB_PATH))

        results = []
        try:
            # Step 1: T1 reads employee salary
            c1 = conn1.cursor()
            c1.execute("SELECT salary FROM EMPLOYEE WHERE emp_id = 8;")
            sal_read_1 = c1.fetchone()[0]
            results.append(f"Step 1 [T1]: Initial read of Driver Rajesh's salary = ${sal_read_1:,.2f}")

            # Step 2: T2 modifies salary and commits
            c2 = conn2.cursor()
            new_salary = sal_read_1 + 5000.00
            c2.execute("UPDATE EMPLOYEE SET salary = ? WHERE emp_id = 8;", (new_salary,))
            conn2.commit()
            results.append(f"Step 2 [T2]: Concurrent transaction raised salary to ${new_salary:,.2f} and COMMITTED.")

            # Step 3: T1 re-reads the same row
            c1.execute("SELECT salary FROM EMPLOYEE WHERE emp_id = 8;")
            sal_read_2 = c1.fetchone()[0]
            results.append(f"Step 3 [T1]: Re-read of same row within same transaction = ${sal_read_2:,.2f}")

            # Cleanup / Revert
            c2.execute("UPDATE EMPLOYEE SET salary = ? WHERE emp_id = 8;", (sal_read_1,))
            conn2.commit()

            return {
                "anomaly": "Non-Repeatable Read (Fuzzy Read - G2a)",
                "definition": "A transaction re-reads data it previously read and finds that data has been modified by a committed concurrent transaction.",
                "allowed_in": ["READ UNCOMMITTED", "READ COMMITTED"],
                "prevented_in": ["REPEATABLE READ", "SERIALIZABLE"],
                "execution_trace": results,
                "conclusion": f"Observed shift from ${sal_read_1:,.2f} to ${sal_read_2:,.2f} within transaction T1."
            }
        finally:
            conn1.close()
            conn2.close()

    @staticmethod
    def demonstrate_phantom_read_concept() -> Dict[str, Any]:
        """Explains Phantom Read: T1 executes a range query; T2 inserts/deletes rows matching the predicate and commits; T1 re-runs range query and gets different row set."""
        return {
            "anomaly": "Phantom Read (A3)",
            "definition": "A transaction executes a query returning a set of rows satisfying a search condition; a concurrent transaction inserts new matching rows and commits; the first transaction re-runs the query and sees new 'phantom' rows.",
            "allowed_in": ["READ UNCOMMITTED", "READ COMMITTED", "REPEATABLE READ (in some engines without predicate locking)"],
            "prevented_in": ["SERIALIZABLE (via Predicate Locking or Index Range Locks)"],
            "scenario": [
                "1. T1: SELECT COUNT(*) FROM SHIPMENT WHERE status = 'DELIVERED'; -> Returns 3",
                "2. T2: INSERT INTO SHIPMENT (...) VALUES (..., 'DELIVERED'); -> COMMIT;",
                "3. T1: SELECT COUNT(*) FROM SHIPMENT WHERE status = 'DELIVERED'; -> Returns 4 (Phantom Row detected!)",
                "4. Resolution: Serializable isolation locks the predicate key space."
            ]
        }

    @staticmethod
    def demonstrate_write_skew_concept() -> Dict[str, Any]:
        """Explains Write Skew: Two transactions concurrently read overlapping state and modify disjoint rows violating a global invariant."""
        return {
            "anomaly": "Write Skew (Serialization Anomaly)",
            "definition": "Two concurrent transactions read common data but update disjoint records, causing a global constraint violation that neither transaction violated individually.",
            "example_in_logichain": "Rule: At least one Manager must be active at NYC Hub (WH-401). T1 unassigns Manager A; T2 concurrently unassigns Manager B. Under Snapshot Isolation both commit, leaving zero managers!",
            "prevented_by": "Strict Serializable 2PL or SELECT ... FOR UPDATE on parent warehouse row."
        }

if __name__ == "__main__":
    sim = IsolationLevelSimulator()
    print("=== NON-REPEATABLE READ DEMO ===")
    res = sim.demonstrate_non_repeatable_read()
    for line in res["execution_trace"]:
        print(line)
    print(res["conclusion"])
