import time
from typing import Dict, Any, List

class TwoPhaseCommitSimulator:
    """Simulates Distributed Two-Phase Commit (2PC) Protocol across Warehouse Nodes.
    Maps to CSE3001 Unit 5 (Distributed Concurrency & System Recovery).
    """

    def __init__(self):
        self.participants = [
            {"node_id": "DEPOT-NYC-401", "name": "Northeast Metro Hub", "status": "ONLINE", "can_commit": True},
            {"node_id": "DEPOT-LAX-402", "name": "Pacific Gateway Depot", "status": "ONLINE", "can_commit": True},
            {"node_id": "DEPOT-CHI-403", "name": "Midwest Central Terminal", "status": "ONLINE", "can_commit": True}
        ]

    def execute_2pc_transaction(self, tx_id: str, simulate_failure_node: str = None) -> Dict[str, Any]:
        logs: List[str] = []
        logs.append(f"=== INITIATING DISTRIBUTED 2PC TRANSACTION: [{tx_id}] ===")
        logs.append(f"Coordinator: Dispatching cross-depot inventory rebalancing...")

        # Phase 1: Prepare Phase
        logs.append("\n--- PHASE 1: PREPARE / VOTING PHASE ---")
        logs.append("Coordinator -> All Participants: PREPARE [Tx: " + tx_id + "]")

        votes: Dict[str, str] = {}
        all_voted_yes = True

        for p in self.participants:
            node = p["node_id"]
            if simulate_failure_node and node == simulate_failure_node:
                votes[node] = "VOTE_ABORT"
                all_voted_yes = False
                logs.append(f"  [Participant {node} ({p['name']})]: Insufficient reserved stock / Network Timeout -> Responded: VOTE_ABORT")
            else:
                votes[node] = "VOTE_COMMIT"
                logs.append(f"  [Participant {node} ({p['name']})]: Local lock acquired & WAL logged -> Responded: VOTE_COMMIT")

        # Phase 2: Decision Phase
        logs.append("\n--- PHASE 2: COMMIT / DECISION PHASE ---")
        if all_voted_yes:
            decision = "GLOBAL_COMMIT"
            logs.append(f"Coordinator: Received unanimous VOTE_COMMIT from all nodes.")
            logs.append(f"Coordinator: Writing <GLOBAL_COMMIT, {tx_id}> to WAL.")
            logs.append(f"Coordinator -> All Participants: GLOBAL_COMMIT")
            for p in self.participants:
                logs.append(f"  [Participant {p['node_id']}]: Applied local changes, released locks, sent ACK.")
            outcome = "TRANSACTION_COMMITTED_SUCCESSFULLY"
        else:
            decision = "GLOBAL_ABORT"
            logs.append(f"Coordinator: At least one participant responded VOTE_ABORT or timed out.")
            logs.append(f"Coordinator: Writing <GLOBAL_ABORT, {tx_id}> to WAL.")
            logs.append(f"Coordinator -> All Participants: GLOBAL_ABORT")
            for p in self.participants:
                logs.append(f"  [Participant {p['node_id']}]: Rolled back local changes, released locks, sent ACK.")
            outcome = "TRANSACTION_ABORTED_SAFELY"

        return {
            "tx_id": tx_id,
            "decision": decision,
            "outcome": outcome,
            "votes": votes,
            "execution_log": logs
        }

if __name__ == "__main__":
    sim = TwoPhaseCommitSimulator()
    print("Scenario 1: Successful 2PC Transaction")
    res1 = sim.execute_2pc_transaction("TX-REBALANCE-2026-01")
    for l in res1["execution_log"]:
        print(l)

    print("\nScenario 2: Failed 2PC Transaction (Participant Abort)")
    res2 = sim.execute_2pc_transaction("TX-REBALANCE-2026-02", simulate_failure_node="DEPOT-CHI-403")
    for l in res2["execution_log"]:
        print(l)
