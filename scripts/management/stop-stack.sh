#!/bin/bash
set -euo pipefail

# AI Development Stack - Stop All Services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🛑 Stopping AI Development Stack...${NC}"

cd "$PROJECT_ROOT"

# Detect Docker Compose version
detect_docker_compose() {
    if command -v docker-compose &> /dev/null; then
        echo "docker-compose"
    elif docker compose version &> /dev/null; then
        echo "docker compose"
    else
        echo -e "${YELLOW}⚠️  Docker Compose not found, skipping Docker services${NC}"
        return 1
    fi
}

# Stop Docker services
echo -e "${BLUE}🐳 Stopping Docker services...${NC}"
if COMPOSE_CMD=$(detect_docker_compose); then
    if $COMPOSE_CMD ps -q | grep -q .; then
        $COMPOSE_CMD down
        echo -e "${GREEN}✅ Docker services stopped${NC}"
    else
        echo -e "${YELLOW}⚠️  No Docker services running${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  Skipping Docker services stop${NC}"
fi

# Stop Ollama service (optional - you might want to keep it running)
echo "Stop Ollama service? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🦙 Stopping Ollama service...${NC}"
    sudo systemctl stop ollama
    echo -e "${GREEN}✅ Ollama service stopped${NC}"
else
    echo -e "${YELLOW}⚠️  Ollama service left running${NC}"
fi

echo -e "${GREEN}✅ AI Development Stack stopped${NC}"