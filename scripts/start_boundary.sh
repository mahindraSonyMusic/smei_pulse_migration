#!/bin/bash
# Bash script to start Boundary connection
# Run this script before executing dbt commands

TARGET_ID=${1:-$BOUNDARY_TARGET_ID}
LISTEN_PORT=${2:-5432}

echo -e "\033[36mStarting Boundary connection to RDS...\033[0m"
echo -e "\033[33mTarget ID: $TARGET_ID\033[0m"
echo -e "\033[33mListen Port: $LISTEN_PORT\033[0m"

if [ -z "$TARGET_ID" ]; then
    echo -e "\033[31mERROR: Target ID is required. Set BOUNDARY_TARGET_ID environment variable or pass as first argument.\033[0m"
    exit 1
fi

echo -e "\n\033[32mStarting Boundary proxy on localhost:$LISTEN_PORT...\033[0m"
echo -e "\033[33mKeep this terminal open while running dbt commands.\033[0m\n"

boundary connect postgres -target-id "$TARGET_ID" -listen-port "$LISTEN_PORT"
