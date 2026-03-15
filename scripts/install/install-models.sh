#!/bin/bash
set -euo pipefail

# AI Models Installation Script
# Downloads and configures optimal models for development and research

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}🧠 Installing AI models for development and research...${NC}"

# Function to check if Ollama is running
wait_for_ollama() {
    local retries=30
    local count=0
    
    while ! curl -s http://localhost:11434/api/version > /dev/null; do
        if [ $count -eq $retries ]; then
            echo -e "${YELLOW}⚠️  Ollama not responding, starting it...${NC}"
            sudo systemctl start ollama || ollama serve &
            sleep 5
        fi
        
        echo "⏳ Waiting for Ollama to start... ($count/$retries)"
        sleep 2
        count=$((count + 1))
        
        if [ $count -gt 60 ]; then
            echo "❌ Ollama failed to start after 2 minutes"
            exit 1
        fi
    done
    
    echo -e "${GREEN}✅ Ollama is ready${NC}"
}

# Wait for Ollama to be ready
wait_for_ollama

# Check available space
echo -e "${BLUE}📊 Checking available disk space...${NC}"
AVAILABLE_GB=$(df --output=avail -BG "$HOME" | tail -n1 | tr -d 'G')
REQUIRED_GB=25

if [ "$AVAILABLE_GB" -lt "$REQUIRED_GB" ]; then
    echo -e "${YELLOW}⚠️  Warning: Only ${AVAILABLE_GB}GB available, need at least ${REQUIRED_GB}GB${NC}"
    echo "Continue anyway? (y/N)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Download models with progress
download_model() {
    local model=$1
    local description=$2
    
    echo -e "${BLUE}📥 Downloading $description...${NC}"
    if ollama pull "$model"; then
        echo -e "${GREEN}✅ $description downloaded successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Failed to download $description${NC}"
        return 1
    fi
}

# Primary coding model (14B - best balance)
download_model "qwen2.5-coder:14b" "Qwen 2.5 Coder 14B (Primary coding model)"

# Research model with long context
download_model "llama3.1:8b" "Llama 3.1 8B (Research and general purpose)"

# Fast coding model for quick tasks  
download_model "qwen2.5-coder:7b" "Qwen 2.5 Coder 7B (Fast coding assistant)"

# Optional: lightweight model for very quick tasks
echo "Download lightweight model for quick tasks? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    download_model "qwen2.5:3b" "Qwen 2.5 3B (Lightweight model)"
fi

# Preload primary models to keep them in memory
echo -e "${BLUE}🔥 Preloading models into memory...${NC}"

# Start models in background to preload them
echo "Preloading Qwen 2.5 Coder 14B..."
ollama run qwen2.5-coder:14b "" &
PID1=$!

echo "Preloading Llama 3.1 8B..."  
ollama run llama3.1:8b "" &
PID2=$!

# Wait for preloading to complete
wait $PID1
wait $PID2

echo -e "${GREEN}✅ Models preloaded and ready for use${NC}"

# Display installed models
echo -e "${BLUE}📋 Installed models:${NC}"
ollama list

# Check memory usage
echo -e "${BLUE}💾 Current memory usage:${NC}"
free -h

echo ""
echo -e "${GREEN}🎯 Model installation complete!${NC}"
echo ""
echo -e "${BLUE}📍 Model recommendations:${NC}"
echo "   • Qwen 2.5 Coder 14B: Primary coding assistant (complex tasks)"
echo "   • Qwen 2.5 Coder 7B: Fast coding assistant (quick tasks)"  
echo "   • Llama 3.1 8B: Research, documentation, long context analysis"
echo ""
echo -e "${BLUE}💡 Usage tips:${NC}"
echo "   • Models stay loaded for 24h (configured in OLLAMA_KEEP_ALIVE)"
echo "   • Switch models instantly in OpenWebUI or OpenCode"
echo "   • Use 'ollama ps' to see active models"