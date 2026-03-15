#!/bin/bash
set -euo pipefail

# Resource Monitoring Script
# Real-time monitoring of AI Development Stack resources

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}📊 AI Development Stack - Resource Monitor${NC}"
echo "=================================================="

# Function to get memory usage percentage
get_memory_usage() {
    free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}'
}

# Function to get CPU usage
get_cpu_usage() {
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}'
}

# Function to get disk usage  
get_disk_usage() {
    df -h "$HOME" | tail -n1 | awk '{print $5}' | sed 's/%//'
}

# Function to get Ollama memory usage
get_ollama_memory() {
    if pgrep ollama > /dev/null; then
        ps -p $(pgrep ollama) -o rss= | awk '{sum+=$1} END {printf "%.1f", sum/1024/1024}'
    else
        echo "0.0"
    fi
}

# Function to get Docker memory usage
get_docker_memory() {
    if command -v docker &> /dev/null; then
        docker stats --no-stream --format "table {{.Container}}\t{{.MemUsage}}" 2>/dev/null | tail -n +2 | awk -F'/' '{sum+=$1} END {printf "%.1f", sum}'
    else
        echo "0.0"
    fi
}

# Continuous monitoring
monitor_resources() {
    while true; do
        clear
        echo -e "${BLUE}📊 AI Development Stack - Resource Monitor${NC}"
        echo "=================================================="
        echo "Press Ctrl+C to exit"
        echo ""
        
        # System resources
        MEM_USAGE=$(get_memory_usage)
        CPU_USAGE=$(get_cpu_usage)
        DISK_USAGE=$(get_disk_usage)
        
        # AI-specific resources
        OLLAMA_MEM=$(get_ollama_memory)
        DOCKER_MEM=$(get_docker_memory)
        
        echo -e "${BLUE}🖥️  System Resources:${NC}"
        printf "%-20s " "CPU Usage:"
        if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
            echo -e "${RED}${CPU_USAGE}%${NC}"
        elif (( $(echo "$CPU_USAGE > 60" | bc -l) )); then
            echo -e "${YELLOW}${CPU_USAGE}%${NC}"
        else
            echo -e "${GREEN}${CPU_USAGE}%${NC}"
        fi
        
        printf "%-20s " "Memory Usage:"
        if (( $(echo "$MEM_USAGE > 90" | bc -l) )); then
            echo -e "${RED}${MEM_USAGE}%${NC}"
        elif (( $(echo "$MEM_USAGE > 75" | bc -l) )); then
            echo -e "${YELLOW}${MEM_USAGE}%${NC}"
        else
            echo -e "${GREEN}${MEM_USAGE}%${NC}"
        fi
        
        printf "%-20s " "Disk Usage:"
        if [ "$DISK_USAGE" -gt 90 ]; then
            echo -e "${RED}${DISK_USAGE}%${NC}"
        elif [ "$DISK_USAGE" -gt 80 ]; then
            echo -e "${YELLOW}${DISK_USAGE}%${NC}"
        else
            echo -e "${GREEN}${DISK_USAGE}%${NC}"
        fi
        
        echo ""
        echo -e "${BLUE}🤖 AI Services:${NC}"
        printf "%-20s " "Ollama Memory:"
        echo -e "${GREEN}${OLLAMA_MEM} GB${NC}"
        
        printf "%-20s " "Docker Memory:"
        echo -e "${GREEN}${DOCKER_MEM} GB${NC}"
        
        # Service status
        echo ""
        echo -e "${BLUE}⚡ Service Status:${NC}"
        
        # Ollama
        printf "%-20s " "Ollama:"
        if curl -s http://localhost:11434/api/version > /dev/null 2>&1; then
            echo -e "${GREEN}✅ RUNNING${NC}"
        else
            echo -e "${RED}❌ STOPPED${NC}"
        fi
        
        # OpenWebUI
        printf "%-20s " "OpenWebUI:"
        if docker ps --filter "name=open-webui" --filter "status=running" | grep -q open-webui; then
            echo -e "${GREEN}✅ RUNNING${NC}"
        else
            echo -e "${RED}❌ STOPPED${NC}"
        fi
        
        # SearXNG
        printf "%-20s " "SearXNG:"
        if docker ps --filter "name=searxng" --filter "status=running" | grep -q searxng; then
            echo -e "${GREEN}✅ RUNNING${NC}"
        else
            echo -e "${RED}❌ STOPPED${NC}"
        fi
        
        # Loaded models
        echo ""
        echo -e "${BLUE}🧠 Loaded Models:${NC}"
        if curl -s http://localhost:11434/api/ps 2>/dev/null | jq -r '.models[]? | "  • \(.name)"' 2>/dev/null; then
            :
        else
            echo "  No models loaded"
        fi
        
        echo ""
        echo "Last updated: $(date '+%H:%M:%S')"
        
        sleep 5
    done
}

# Start monitoring
monitor_resources