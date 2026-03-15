#!/bin/bash
set -euo pipefail

# OpenCode.ai Smart Installation Script

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

echo -e "${BLUE}🤖 OpenCode.ai Smart Setup (MIT Licensed)...${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${CYAN}📋 $1${NC}"
}

# Check if OpenCode is already installed
if command -v opencode &> /dev/null; then
    CURRENT_VERSION=$(opencode --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}✅ OpenCode already installed!${NC}"
    echo -e "${CYAN}   Version: ${CURRENT_VERSION}${NC}"
    echo ""
    SKIP_INSTALL=true
else
    echo -e "${YELLOW}📥 OpenCode not found, installing...${NC}"
    SKIP_INSTALL=false
fi

# Install OpenCode if not already present
if [ "$SKIP_INSTALL" = false ]; then
    echo -e "${BLUE}🔍 Checking available installation methods...${NC}"
    
    if command -v npm &> /dev/null; then
        echo -e "${BLUE}📦 Installing via npm (recommended)...${NC}"
        npm install -g opencode-ai@latest
        print_status "Installed via npm"
        
    elif command -v brew &> /dev/null; then
        echo -e "${BLUE}🍺 Installing via Homebrew...${NC}"
        brew install anomalyco/tap/opencode
        print_status "Installed via Homebrew"
        
    elif command -v curl &> /dev/null; then
        echo -e "${BLUE}📥 Installing via install script...${NC}"
        curl -fsSL https://opencode.ai/install | bash
        print_status "Installed via curl script"
        
    else
        echo -e "${RED}❌ No supported package manager found${NC}"
        echo "Please install one of: npm, brew, or curl"
        exit 1
    fi
    
    # Verify installation
    if command -v opencode &> /dev/null; then
        echo -e "${GREEN}✅ OpenCode installed successfully!${NC}"
        echo -e "${CYAN}   Version: $(opencode --version)${NC}"
        echo ""
    else
        echo -e "${RED}❌ OpenCode installation failed${NC}"
        exit 1
    fi
else
    echo -e "${CYAN}⏭️  Skipping installation, proceeding to configuration...${NC}"
    echo ""
fi

# Setup configuration directory
echo -e "${BLUE}📁 Setting up configuration...${NC}"
mkdir -p ~/.config/opencode

# Check and setup main configuration
if [ -f ~/.config/opencode/opencode.json ]; then
    echo -e "${GREEN}✅ OpenCode configuration already exists${NC}"
    echo -e "${CYAN}   Location: ~/.config/opencode/opencode.json${NC}"
    
    # Ask if user wants to update with project settings
    echo ""
    echo -e "${YELLOW}🔄 Would you like to update your configuration with this project's optimized settings?${NC}"
    echo -e "${CYAN}   This will backup your current config and apply our Ollama + local model setup${NC}"
    read -p "Update configuration? (y/N): " -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        # Backup existing config
        BACKUP_FILE=~/.config/opencode/opencode.json.backup.$(date +%Y%m%d_%H%M%S)
        cp ~/.config/opencode/opencode.json "$BACKUP_FILE"
        echo -e "${GREEN}📋 Current config backed up to: ${BACKUP_FILE}${NC}"
        
        # Apply new configuration
        cp "$PROJECT_ROOT/config/opencode/opencode.json" ~/.config/opencode/
        echo -e "${GREEN}📋 Configuration updated with project settings${NC}"
    else
        echo -e "${YELLOW}⏭️  Keeping existing configuration${NC}"
    fi
else
    # No existing config, copy project config
    cp "$PROJECT_ROOT/config/opencode/opencode.json" ~/.config/opencode/
    echo -e "${GREEN}📋 OpenCode configuration installed${NC}"
    echo -e "${CYAN}   Location: ~/.config/opencode/opencode.json${NC}"
fi

# Check and setup TUI configuration
if [ -f ~/.config/opencode/tui.json ]; then
    echo -e "${GREEN}✅ TUI configuration already exists${NC}"
    echo -e "${CYAN}   Location: ~/.config/opencode/tui.json${NC}"
else
    cp "$PROJECT_ROOT/config/opencode/tui.json" ~/.config/opencode/
    echo -e "${GREEN}🎨 TUI configuration installed${NC}"
    echo -e "${CYAN}   Location: ~/.config/opencode/tui.json${NC}"
fi

# Create/update development configuration
echo ""
echo -e "${BLUE}⚙️  Setting up development configuration...${NC}"

DEV_CONFIG=~/.config/opencode/opencode-dev.json
cat > "$DEV_CONFIG" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama-dev": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local Development",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen2.5-coder:7b": {
          "name": "Quick Coder",
          "limit": {
            "context": 32768,
            "output": 4096
          }
        }
      }
    }
  },
  "model": "qwen2.5-coder:7b",
  "agent": {
    "dev": {
      "model": "qwen2.5-coder:7b",
      "description": "Fast development agent for quick tasks"
    }
  },
  "options": {
    "debug": true,
    "auto_save": false
  }
}
EOF

echo -e "${GREEN}📋 Development configuration created${NC}"
echo -e "${CYAN}   Location: ${DEV_CONFIG}${NC}"

# Test OpenCode functionality
echo ""
echo -e "${BLUE}🧪 Testing OpenCode installation...${NC}"

if opencode --help > /dev/null 2>&1; then
    echo -e "${GREEN}✅ OpenCode is working correctly${NC}"
    
    # Test Ollama connection if available
    if command -v ollama &> /dev/null && ollama list &> /dev/null; then
        echo -e "${GREEN}✅ Ollama connection available${NC}"
        
        # Check if our configured models are available
        if ollama list | grep -q "qwen2.5-coder:14b"; then
            echo -e "${GREEN}✅ Qwen2.5-Coder 14B model available${NC}"
        else
            echo -e "${YELLOW}⚠️  Qwen2.5-Coder 14B model not found${NC}"
            echo -e "${CYAN}   Run: ollama pull qwen2.5-coder:14b${NC}"
        fi
        
        if ollama list | grep -q "llama3.1:8b"; then
            echo -e "${GREEN}✅ Llama 3.1 8B model available${NC}"
        else
            echo -e "${YELLOW}⚠️  Llama 3.1 8B model not found${NC}"
            echo -e "${CYAN}   Run: ollama pull llama3.1:8b${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Ollama not available or not running${NC}"
        echo -e "${CYAN}   OpenCode will work with other providers when configured${NC}"
    fi
else
    echo -e "${YELLOW}⚠️  OpenCode test failed - may need to restart terminal${NC}"
    echo -e "${CYAN}   Try: source ~/.bashrc && opencode --version${NC}"
fi

echo ""
echo -e "${GREEN}🎯 OpenCode setup complete!${NC}"
echo ""
echo -e "${BLUE}📍 Quick Start:${NC}"
echo -e "${CYAN}   • Test installation: ${NC}opencode --version"
echo -e "${CYAN}   • Start interactive: ${NC}opencode"
echo -e "${CYAN}   • Get help: ${NC}opencode --help"
echo ""
echo -e "${BLUE}💡 Configuration files:${NC}"
echo -e "${CYAN}   • Main config: ~/.config/opencode/opencode.json${NC}"
echo -e "${CYAN}   • TUI config: ~/.config/opencode/tui.json${NC}"
echo -e "${CYAN}   • Dev config: ~/.config/opencode/opencode-dev.json${NC}"
echo ""
echo -e "${BLUE}🚀 Usage examples:${NC}"
echo -e "${CYAN}   • Code help: ${NC}opencode \"Explain this code\" --file main.py"
echo -e "${CYAN}   • Generate API: ${NC}opencode \"Create a REST API in Go\""
echo -e "${CYAN}   • Code review: ${NC}opencode \"Review for issues\" --file src/handlers.go"
echo ""
echo -e "${BLUE}💰 Commercial Freedom:${NC}"
echo -e "${GREEN}   ✅ MIT License - No commercial restrictions!${NC}"
echo -e "${CYAN}   ✅ Use freely in your company and products${NC}"
echo -e "${CYAN}   ✅ Build and sell applications using OpenCode${NC}"
echo ""

# Check for shell restart requirement
if [ "$SKIP_INSTALL" = false ]; then
    echo -e "${YELLOW}🔄 Important: You may need to restart your terminal or run:${NC}"
    echo -e "${CYAN}   source ~/.bashrc${NC}"
    echo -e "${CYAN}   # or source ~/.zshrc (if using zsh)${NC}"
fi