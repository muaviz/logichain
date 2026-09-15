#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "LogiChain Concurrency, Deadlock & 2PC Test Suite"
echo "=========================================================="

echo -e "\n[1/3] Running Transaction Isolation Level Anomaly Tests..."
python3 -m src.simulations.isolation_runner

echo -e "\n[2/3] Running Deadlock & Wait-For Graph Simulator..."
python3 -m src.simulations.deadlock_runner

echo -e "\n[3/3] Running Distributed Two-Phase Commit Simulator..."
python3 -m src.simulations.two_phase_commit

echo -e "\nAll concurrency tests executed successfully!"
