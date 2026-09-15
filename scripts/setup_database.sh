#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "LogiChain DBMS: Initializing Database & Environment..."
echo "=========================================================="

python3 -m pip install -r requirements.txt --quiet
python3 -m src.schema_loader

echo "=========================================================="
echo "LogiChain database initialization complete!"
echo "Run 'python3 -m src.cli' to launch the interactive terminal."
echo "=========================================================="
