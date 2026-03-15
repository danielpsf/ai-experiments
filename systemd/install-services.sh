#!/bin/bash
set -euo pipefail

# Install systemd services for AI Development Stack

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}⚙️ Installing systemd services...${NC}"

# Check if running with proper permissions
if [ "$EUID" -eq 0 ]; then
    echo -e "${YELLOW}⚠️  This script should be run as a regular user, not root${NC}"
    echo "It will use sudo when needed"
fi

# Install Ollama service
echo "Installing Ollama service..."
sudo cp "$SCRIPT_DIR/ollama.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ollama.service
echo -e "${GREEN}✅ Ollama service installed${NC}"

# Install AI Stack service
echo "Installing AI Stack service..."
sudo cp "$SCRIPT_DIR/ai-stack.service" /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable ai-stack.service
echo -e "${GREEN}✅ AI Stack service installed${NC}"

# Start services
echo -e "${BLUE}🚀 Starting services...${NC}"
sudo systemctl start ollama.service

# Wait a moment for Ollama to start
sleep 3

# Start AI stack
sudo systemctl start ai-stack.service

echo ""
echo -e "${GREEN}✅ Systemd services installed and started!${NC}"
echo ""
echo -e "${BLUE}📍 Service Management:${NC}"
echo "   Status:   sudo systemctl status ollama ai-stack"
echo "   Start:    sudo systemctl start ollama ai-stack"
echo "   Stop:     sudo systemctl stop ai-stack ollama"
echo "   Restart:  sudo systemctl restart ollama ai-stack"
echo "   Logs:     sudo journalctl -u ollama -f"
echo ""
echo -e "${BLUE}🔄 Auto-startup: Services will start automatically on boot${NC}"