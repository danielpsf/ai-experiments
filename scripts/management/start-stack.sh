#!/bin/bash
set -euo pipefail

# AI Development Stack - Start All Services
# Starts Ollama (native) and Docker services in correct order

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting AI Development Stack...${NC}"

# Load environment if available
if [ -f "$PROJECT_ROOT/.env" ]; then
    set -a
    source "$PROJECT_ROOT/.env"
    set +a
fi

cd "$PROJECT_ROOT"

# Function to check service health
check_service() {
    local service=$1
    local url=$2
    local max_attempts=${3:-30}
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s "$url" > /dev/null 2>&1; then
            echo -e "${GREEN}✅ $service is healthy${NC}"
            return 0
        fi
        
        echo "⏳ Waiting for $service... ($attempt/$max_attempts)"
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo -e "${RED}❌ $service health check failed${NC}"
    return 1
}

# Start Ollama service
echo -e "${BLUE}🦙 Starting Ollama service...${NC}"
if systemctl is-active --quiet ollama; then
    echo -e "${GREEN}✅ Ollama service already running${NC}"
else
    sudo systemctl start ollama
    echo -e "${GREEN}✅ Ollama service started${NC}"
fi

# Wait for Ollama to be ready
echo -e "${BLUE}⏳ Waiting for Ollama to be ready...${NC}"
if check_service "Ollama" "http://localhost:11434/api/version"; then
    echo -e "${GREEN}✅ Ollama is ready${NC}"
else
    echo -e "${RED}❌ Ollama failed to start${NC}"
    exit 1
fi

# Load primary models if not already loaded
echo -e "${BLUE}🔥 Ensuring models are loaded...${NC}"

# Check if models are already loaded
LOADED_MODELS=$(curl -s http://localhost:11434/api/ps | jq -r '.models[].name' 2>/dev/null || echo "")

if echo "$LOADED_MODELS" | grep -q "qwen2.5-coder:14b"; then
    echo -e "${GREEN}✅ Qwen 2.5 Coder 14B already loaded${NC}"
else
    echo "Loading Qwen 2.5 Coder 14B..."
    ollama run qwen2.5-coder:14b "" &
fi

if echo "$LOADED_MODELS" | grep -q "llama3.1:8b"; then
    echo -e "${GREEN}✅ Llama 3.1 8B already loaded${NC}"
else
    echo "Loading Llama 3.1 8B..."
    ollama run llama3.1:8b "" &
fi

# Wait for model loading to complete
wait

# Start Docker services
echo -e "${BLUE}🐳 Starting Docker services...${NC}"
if docker-compose ps | grep -q "Up"; then
    echo -e "${YELLOW}⚠️  Some Docker services already running${NC}"
    docker-compose restart
else
    docker-compose up -d
fi

# Health checks for Docker services
echo -e "${BLUE}🏥 Performing health checks...${NC}"

# Check Redis
if check_service "Redis" "http://localhost:6380"; then
    echo -e "${GREEN}✅ Redis is healthy${NC}"
else
    echo -e "${YELLOW}⚠️  Redis health check failed (might be normal)${NC}"
fi

# Check SearXNG
if check_service "SearXNG" "http://localhost:8081"; then
    echo -e "${GREEN}✅ SearXNG is healthy${NC}"
else
    echo -e "${RED}❌ SearXNG health check failed${NC}"
fi

# Check OpenWebUI
if check_service "OpenWebUI" "http://localhost:3001"; then
    echo -e "${GREEN}✅ OpenWebUI is healthy${NC}"
else
    echo -e "${RED}❌ OpenWebUI health check failed${NC}"
fi

# Final status check
echo -e "${BLUE}📊 Service Status:${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}🎉 AI Development Stack is ready!${NC}"
echo ""
echo -e "${BLUE}📍 Access Points:${NC}"
echo "   🌐 OpenWebUI: http://localhost:3001"
echo "   🔍 SearXNG: http://localhost:8081"
echo "   🦙 Ollama API: http://localhost:11434"
echo ""
echo -e "${BLUE}💻 Terminal AI:${NC}"
echo "   Run: opencode"
echo ""
echo -e "${BLUE}📊 Monitoring:${NC}"
echo "   Health check: ./scripts/monitoring/health-check.sh"
echo "   Logs: ./scripts/monitoring/log-viewer.sh"
echo "   Resources: ./scripts/monitoring/monitor-resources.sh"