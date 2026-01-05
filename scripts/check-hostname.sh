#!/bin/bash

# Demo pre-commit hook that checks hostname condition
# This hook demonstrates how pre-commit hooks can fail based on conditions

echo "Running demo pre-commit hook..."

# Get current hostname
CURRENT_HOST=$(hostname)
echo "Current hostname: $CURRENT_HOST"

# Check if hostname matches the condition (from your config: host = ["anubis", "horus"])
if [[ "$CURRENT_HOST" == "anubis" || "$CURRENT_HOST" == "horus" ]]; then
    echo "✓ Hostname condition passed: $CURRENT_HOST"
    echo "✓ Pre-commit hook passed"
    exit 0
else
    echo "✗ Hostname condition failed: expected 'anubis' or 'horus', got '$CURRENT_HOST'"
    echo "✗ Pre-commit hook failed - commit blocked"
    exit 1
fi
