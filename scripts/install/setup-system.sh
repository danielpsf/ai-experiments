#!/bin/bash
set -euo pipefail

# AI Development Stack - System Setup
# Repository: github.com/danielpsf/ai-experiments

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Setting up AI Development Stack...${NC}"
echo "Project root: $PROJECT_ROOT"

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check system requirements
echo -e "${BLUE}📋 Checking system requirements...${NC}"

if ! command -v docker &> /dev/null; then
    print_error "Docker is required but not installed"
    echo "Please install Docker: https://docs.docker.com/engine/install/"
    exit 1
fi

# Check for Docker Compose (both V1 and V2)
if command -v docker-compose &> /dev/null; then
    COMPOSE_CMD="docker-compose"
    COMPOSE_VERSION=$(docker-compose version --short 2>/dev/null || echo "unknown")
    print_status "Docker Compose V1 found (${COMPOSE_VERSION})"
elif docker compose version &> /dev/null; then
    COMPOSE_CMD="docker compose"
    COMPOSE_VERSION=$(docker compose version --short 2>/dev/null || echo "unknown")
    print_status "Docker Compose V2 found (${COMPOSE_VERSION})"
else
    print_error "Docker Compose is required but not installed" 
    echo "Please install Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

print_status "Docker and Docker Compose found"

# Check if user is in docker group
if ! groups $USER | grep -q docker; then
    print_warning "User $USER is not in docker group"
    echo "Adding user to docker group..."
    sudo usermod -aG docker $USER
    print_warning "Please log out and log back in, then run this script again"
    exit 1
fi

# System optimization
echo -e "${BLUE}⚡ Optimizing system settings...${NC}"
sudo sysctl -w vm.swappiness=10 > /dev/null
sudo sysctl -w vm.dirty_ratio=60 > /dev/null  
sudo sysctl -w vm.dirty_background_ratio=2 > /dev/null

# Make settings persistent
if ! grep -q "vm.swappiness" /etc/sysctl.conf; then
    echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf > /dev/null
    echo "vm.dirty_ratio=60" | sudo tee -a /etc/sysctl.conf > /dev/null
    echo "vm.dirty_background_ratio=2" | sudo tee -a /etc/sysctl.conf > /dev/null
fi

print_status "System optimization applied"

# Install Ollama natively
echo -e "${BLUE}🦙 Checking Ollama installation...${NC}"
if ! command -v ollama &> /dev/null; then
    echo -e "${BLUE}📥 Installing Ollama...${NC}"
    curl -fsSL https://ollama.com/install.sh | sh
    print_status "Ollama installed"
else
    OLLAMA_VERSION=$(ollama --version 2>/dev/null | head -n1 || echo "unknown")
    echo -e "${GREEN}✅ Ollama already installed${NC}"
    echo -e "${GREEN}   Version: ${OLLAMA_VERSION}${NC}"
    print_status "Ollama found, proceeding to configuration"
fi

# Install OpenCode (MIT Licensed AI Assistant)
echo -e "${BLUE}🤖 Installing OpenCode...${NC}"
"$SCRIPT_DIR/install-opencode.sh"

# Setup environment
echo -e "${BLUE}🔧 Setting up environment...${NC}"
if [ ! -f "$PROJECT_ROOT/.env" ]; then
    cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
    
    # Generate secrets
    WEBUI_SECRET=$(openssl rand -hex 32)
    SEARXNG_SECRET=$(openssl rand -hex 32)
    
    sed -i "s/your-secret-key-here/$WEBUI_SECRET/" "$PROJECT_ROOT/.env"
    sed -i "s/your-searxng-secret-here/$SEARXNG_SECRET/" "$PROJECT_ROOT/.env"
    
    print_status "Environment file created with generated secrets"
else
    print_status "Environment file already exists"
fi

# Update SearXNG config with secret
SEARXNG_SECRET=$(grep "SEARXNG_SECRET=" "$PROJECT_ROOT/.env" | cut -d'=' -f2)
sed -i "s/your-searxng-secret-here/$SEARXNG_SECRET/" "$PROJECT_ROOT/config/searxng/settings.yml"

# Create data directories
echo -e "${BLUE}📁 Creating data directories...${NC}"
mkdir -p "$PROJECT_ROOT/data/open-webui"
mkdir -p "$PROJECT_ROOT/data/searxng"

# Set proper permissions
chown -R $USER:$USER "$PROJECT_ROOT/data"

# Install systemd services
echo -e "${BLUE}⚙️ Installing systemd services...${NC}"
"$PROJECT_ROOT/systemd/install-services.sh"

# Download AI models
echo -e "${BLUE}🧠 Downloading AI models...${NC}"
"$SCRIPT_DIR/install-models.sh"

# Set executable permissions on scripts
echo -e "${BLUE}🔐 Setting script permissions...${NC}"
chmod +x "$PROJECT_ROOT/scripts/management/"*
chmod +x "$PROJECT_ROOT/scripts/monitoring/"*
chmod +x "$PROJECT_ROOT/scripts/backup/"*

print_status "Script permissions set"

echo ""
echo -e "${GREEN}🎉 AI Development Stack setup complete!${NC}"
echo ""
echo -e "${BLUE}📍 Next steps:${NC}"
echo "   1. Start the stack: ./scripts/management/start-stack.sh"
echo "   2. Access OpenWebUI: http://localhost:3001"
echo "   3. Access SearXNG: http://localhost:8081"
echo "   4. Use terminal AI: opencode"
echo ""
echo -e "${BLUE}📚 Documentation: docs/QUICK_START.md${NC}"
echo ""
echo -e "${YELLOW}💡 Tip: Run './scripts/monitoring/health-check.sh' to verify everything is working${NC}"