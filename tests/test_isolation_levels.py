import pytest
from src.simulations.isolation_runner import IsolationLevelSimulator
from src.simulations.two_phase_commit import TwoPhaseCommitSimulator

def test_non_repeatable_read_simulation():
    sim = IsolationLevelSimulator()
    res = sim.demonstrate_non_repeatable_read()
    assert "execution_trace" in res
    assert len(res["execution_trace"]) == 3
    assert res["anomaly"].startswith("Non-Repeatable Read")

def test_two_phase_commit_success():
    sim = TwoPhaseCommitSimulator()
    res = sim.execute_2pc_transaction("TEST-TX-001")
    assert res["decision"] == "GLOBAL_COMMIT"
    assert res["outcome"] == "TRANSACTION_COMMITTED_SUCCESSFULLY"

def test_two_phase_commit_abort():
    sim = TwoPhaseCommitSimulator()
    res = sim.execute_2pc_transaction("TEST-TX-002", simulate_failure_node="DEPOT-CHI-403")
    assert res["decision"] == "GLOBAL_ABORT"
    assert res["outcome"] == "TRANSACTION_ABORTED_SAFELY"
