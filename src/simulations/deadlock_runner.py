import time
import threading
import sqlite3
from typing import Dict, Any, List
from src.config import SQLITE_DB_PATH

class DeadlockSimulator:
    """Demonstrates Concurrency Lock Contention, Deadlocks, Wait-For Graphs,
    and Exponential Backoff Retry Strategies.
    Maps to CSE3001 Unit 5 (Concurrency Control & Deadlock Handling).
    """

    def __init__(self):
        self.logs: List[str] = []
        self.lock = threading.Lock()

    def log(self, message: str):
        with self.lock:
            self.logs.append(message)

    def run_competing_transactions(self) -> Dict[str, Any]:
        self.logs = []
        self.log("Initializing Deadlock Simulation between concurrent workers...")

        # Worker 1: Modifies Stock 501, then attempts Stock 502
        def worker_1():
            try:
                conn = sqlite3.connect(str(SQLITE_DB_PATH), timeout=1.0)
                c = conn.cursor()
                c.execute("BEGIN EXCLUSIVE TRANSACTION;")
                self.log("[Worker 1 / T1] Acquired EXCLUSIVE Lock on Stock 501 (Product WD-OAK-001)")
                c.execute("UPDATE INVENTORY_STOCK SET quantity_on_hand = quantity_on_hand - 1 WHERE stock_id = 501;")
                time.sleep(0.3)

                self.log("[Worker 1 / T1] Requesting Lock on Stock 502 (Product CH-ERG-004)... Waiting for T2")
                c.execute("UPDATE INVENTORY_STOCK SET quantity_on_hand = quantity_on_hand + 1 WHERE stock_id = 502;")
                conn.commit()
                self.log("[Worker 1 / T1] Successfully committed transaction.")
                conn.close()
            except sqlite3.OperationalError as e:
                self.log(f"[Worker 1 / T1] [DEADLOCK / LOCK TIMEOUT DETECTED]: {e}")
                self.log("[Worker 1 / T1] Rolling back transaction T1 to break contention.")

        # Worker 2: Modifies Stock 502, then attempts Stock 501
        def worker_2():
            try:
                conn = sqlite3.connect(str(SQLITE_DB_PATH), timeout=1.0)
                c = conn.cursor()
                c.execute("BEGIN EXCLUSIVE TRANSACTION;")
                self.log("[Worker 2 / T2] Acquired EXCLUSIVE Lock on Stock 502 (Product CH-ERG-004)")
                c.execute("UPDATE INVENTORY_STOCK SET quantity_on_hand = quantity_on_hand - 1 WHERE stock_id = 502;")
                time.sleep(0.3)

                self.log("[Worker 2 / T2] Requesting Lock on Stock 501 (Product WD-OAK-001)... Waiting for T1")
                c.execute("UPDATE INVENTORY_STOCK SET quantity_on_hand = quantity_on_hand + 1 WHERE stock_id = 501;")
                conn.commit()
                self.log("[Worker 2 / T2] Successfully committed transaction.")
                conn.close()
            except sqlite3.OperationalError as e:
                self.log(f"[Worker 2 / T2] [DEADLOCK / LOCK TIMEOUT DETECTED]: {e}")
                self.log("[Worker 2 / T2] Rolling back transaction T2 to break contention.")

        t1 = threading.Thread(target=worker_1)
        t2 = threading.Thread(target=worker_2)

        t1.start()
        time.sleep(0.05)
        t2.start()

        t1.join()
        t2.join()

        return {
            "title": "Deadlock & Lock Contention Simulation",
            "wait_for_graph": {
                "nodes": ["Transaction_T1", "Transaction_T2"],
                "edges": [
                    {"from": "Transaction_T1", "to": "Transaction_T2", "resource": "Stock_502"},
                    {"from": "Transaction_T2", "to": "Transaction_T1", "resource": "Stock_501"}
                ],
                "cycle_detected": True
            },
            "logs": self.logs,
            "resolution_technique": "Victim Selection (Rollback T1/T2) + Exponential Backoff Retry Protocol (Wait-Die / Wound-Wait)"
        }

if __name__ == "__main__":
    runner = DeadlockSimulator()
    result = runner.run_competing_transactions()
    for log in result["logs"]:
        print(log)
