#!/bin/bash
set -euo pipefail

# AI Development Stack - Health Check
# Comprehensive health monitoring for all services

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🏥 AI Development Stack Health Check${NC}"
echo "=================================================="

# Function to check service health
check_service() {
    local name=$1
    local url=$2
    local expected_status=${3:-200}
    
    printf "%-20s " "$name:"
    
    if response=$(curl -s -o /dev/null -w "%{http_code}" "$url" 2>/dev/null); then
        if [ "$response" -eq "$expected_status" ] || [ "$response" -eq 200 ]; then
            echo -e "${GREEN}✅ HEALTHY (HTTP $response)${NC}"
            return 0
        else
            echo -e "${YELLOW}⚠️  WARNING (HTTP $response)${NC}"
            return 1
        fi
    else
        echo -e "${RED}❌ UNREACHABLE${NC}"
        return 1
    fi
}

# Function to check systemd service
check_systemd_service() {
    local name=$1
    local service=$2
    
    printf "%-20s " "$name:"
    
    if systemctl is-active --quiet "$service"; then
        echo -e "${GREEN}✅ RUNNING${NC}"
        return 0
    else
        echo -e "${RED}❌ STOPPED${NC}"
        return 1
    fi
}

# Function to check docker container
check_docker_container() {
    local name=$1
    local container=$2
    
    printf "%-20s " "$name:"
    
    if docker ps --filter "name=$container" --filter "status=running" | grep -q "$container"; then
        echo -e "${GREEN}✅ RUNNING${NC}"
        return 0
    else
        echo -e "${RED}❌ STOPPED${NC}"
        return 1
    fi
}

echo -e "${BLUE}🔍 Service Health:${NC}"

# Check core services
ollama_ok=false
if check_systemd_service "Ollama Service" "ollama"; then
    if check_service "Ollama API" "http://localhost:11434/api/version"; then
        ollama_ok=true
    fi
fi

# Check Docker services
check_docker_container "OpenWebUI" "open-webui"
openwebui_ok=$?

check_docker_container "SearXNG" "searxng"
searxng_ok=$?

check_docker_container "Redis" "redis-ai-stack"
redis_ok=$?

# Check web interfaces
echo ""
echo -e "${BLUE}🌐 Web Interface Health:${NC}"
check_service "OpenWebUI Web" "http://localhost:3001"
check_service "SearXNG Web" "http://localhost:8081"

# Check API endpoints
echo ""
echo -e "${BLUE}🔌 API Health:${NC}"
check_service "Ollama API" "http://localhost:11434/api/tags"

# Test SearXNG search
printf "%-20s " "SearXNG Search:"
if search_result=$(curl -s "http://localhost:8081/search?q=test&format=json" 2>/dev/null); then
    if echo "$search_result" | grep -q "results"; then
        echo -e "${GREEN}✅ WORKING${NC}"
    else
        echo -e "${YELLOW}⚠️  LIMITED${NC}"
    fi
else
    echo -e "${RED}❌ FAILED${NC}"
fi

# Check AI models
echo ""
echo -e "${BLUE}🧠 AI Models:${NC}"

if [ "$ollama_ok" = true ]; then
    # List loaded models
    if loaded_models=$(curl -s http://localhost:11434/api/ps 2>/dev/null); then
        echo "Loaded models:"
        echo "$loaded_models" | jq -r '.models[]? | "  • \(.name) (\(.size_vram/1024/1024/1024 | round)GB)"' 2>/dev/null || echo "  No models currently loaded"
    fi
    
    echo ""
    echo "Available models:"
    ollama list 2>/dev/null | tail -n +2 | while read -r line; do
        if [ -n "$line" ]; then
            echo "  • $line"
        fi
    done
else
    echo -e "${RED}❌ Cannot check models - Ollama not running${NC}"
fi

# System resources
echo ""
echo -e "${BLUE}💾 System Resources:${NC}"

# Memory usage
mem_info=$(free -h | grep "Mem:")
mem_used=$(echo $mem_info | awk '{print $3}')
mem_total=$(echo $mem_info | awk '{print $2}')
mem_percent=$(free | grep "Mem:" | awk '{printf "%.1f", $3/$2 * 100.0}')

printf "%-20s " "Memory Usage:"
if (( $(echo "$mem_percent > 90" | bc -l) )); then
    echo -e "${RED}❌ HIGH ($mem_used/$mem_total - $mem_percent%)${NC}"
elif (( $(echo "$mem_percent > 75" | bc -l) )); then
    echo -e "${YELLOW}⚠️  MODERATE ($mem_used/$mem_total - $mem_percent%)${NC}"
else
    echo -e "${GREEN}✅ GOOD ($mem_used/$mem_total - $mem_percent%)${NC}"
fi

# Disk usage
disk_usage=$(df -h "$HOME" | tail -n1 | awk '{print $5}' | sed 's/%//')
disk_avail=$(df -h "$HOME" | tail -n1 | awk '{print $4}')

printf "%-20s " "Disk Space:"
if [ "$disk_usage" -gt 90 ]; then
    echo -e "${RED}❌ LOW ($disk_avail available)${NC}"
elif [ "$disk_usage" -gt 80 ]; then
    echo -e "${YELLOW}⚠️  MODERATE ($disk_avail available)${NC}"
else
    echo -e "${GREEN}✅ GOOD ($disk_avail available)${NC}"
fi

# CPU load
load_avg=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
cpu_cores=$(nproc)

printf "%-20s " "CPU Load:"
if (( $(echo "$load_avg > $cpu_cores * 0.8" | bc -l) )); then
    echo -e "${YELLOW}⚠️  HIGH ($load_avg)${NC}"
else
    echo -e "${GREEN}✅ GOOD ($load_avg)${NC}"
fi

# Network connectivity
echo ""
echo -e "${BLUE}🌐 Network Connectivity:${NC}"

printf "%-20s " "Internet:"
if ping -c 1 google.com > /dev/null 2>&1; then
    echo -e "${GREEN}✅ CONNECTED${NC}"
else
    echo -e "${RED}❌ NO CONNECTION${NC}"
fi

# Docker network
printf "%-20s " "Docker Network:"
if docker network ls | grep -q "ai-stack"; then
    echo -e "${GREEN}✅ ACTIVE${NC}"
else
    echo -e "${RED}❌ MISSING${NC}"
fi

# Crush/OpenCode
echo ""
echo -e "${BLUE}🔨 Terminal AI:${NC}"

printf "%-20s " "Crush Install:"
if command -v crush &> /dev/null; then
    echo -e "${GREEN}✅ INSTALLED${NC}"
    
    printf "%-20s " "Crush Config:"
    if [ -f ~/.config/crush/crush.json ]; then
        echo -e "${GREEN}✅ CONFIGURED${NC}"
    else
        echo -e "${YELLOW}⚠️  NOT CONFIGURED${NC}"
    fi
else
    echo -e "${RED}❌ NOT INSTALLED${NC}"
fi

# Summary
echo ""
echo "=================================================="

# Count healthy services
healthy_services=0
total_services=4

[ "$ollama_ok" = true ] && healthy_services=$((healthy_services + 1))
[ "$openwebui_ok" = true ] && healthy_services=$((healthy_services + 1))
[ "$searxng_ok" = true ] && healthy_services=$((healthy_services + 1))
[ "$redis_ok" = true ] && healthy_services=$((healthy_services + 1))

if [ $healthy_services -eq $total_services ]; then
    echo -e "${GREEN}🎉 All services are healthy! ($healthy_services/$total_services)${NC}"
elif [ $healthy_services -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Partial system health ($healthy_services/$total_services services running)${NC}"
    echo "Run './scripts/management/start-stack.sh' to start missing services"
else
    echo -e "${RED}❌ System is down (0/$total_services services running)${NC}"
    echo "Run './scripts/management/start-stack.sh' to start the stack"
fi

echo ""
echo -e "${BLUE}💡 Quick Actions:${NC}"
echo "   Start stack:     ./scripts/management/start-stack.sh"
echo "   Stop stack:      ./scripts/management/stop-stack.sh"
echo "   View logs:       ./scripts/monitoring/log-viewer.sh"
echo "   Monitor:         ./scripts/monitoring/monitor-resources.sh"