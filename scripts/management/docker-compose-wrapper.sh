#!/bin/bash
# Docker Compose wrapper script for systemd service

PROJECT_ROOT="/home/daniel/Documents/projects/ai-experiments"
cd "$PROJECT_ROOT"

# Detect Docker Compose version
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
else
    echo "Error: Docker Compose not found"
    exit 1
fi

# Execute the command based on the first argument
case "$1" in
    "up")
        $COMPOSE_CMD up -d
        ;;
    "down")
        $COMPOSE_CMD down
        ;;
    "restart")
        $COMPOSE_CMD restart
        ;;
    *)
        echo "Usage: $0 {up|down|restart}"
        exit 1
        ;;
esac