#!/bin/bash
set -euo pipefail

# OpenCode.ai Installation Script

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🤖 Installing OpenCode.ai (MIT Licensed)...${NC}"

# Check for preferred installation methods
if command -v npm &> /dev/null; then
    echo -e "${BLUE}📦 Installing via npm (recommended)...${NC}"
    npm install -g opencode-ai@latest
    
elif command -v brew &> /dev/null; then
    echo -e "${BLUE}🍺 Installing via Homebrew...${NC}"
    brew install anomalyco/tap/opencode
    
elif command -v curl &> /dev/null; then
    echo -e "${BLUE}📥 Installing via install script...${NC}"
    curl -fsSL https://opencode.ai/install | bash
    
else
    echo -e "${RED}❌ No supported package manager found${NC}"
    echo "Please install one of: npm, brew, or curl"
    exit 1
fi

# Verify installation
if command -v opencode &> /dev/null; then
    echo -e "${GREEN}✅ OpenCode installed successfully!${NC}"
    echo "Version: $(opencode --version)"
else
    echo -e "${RED}❌ OpenCode installation failed${NC}"
    exit 1
fi

# Setup configuration
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
mkdir -p ~/.config/opencode

if [ ! -f ~/.config/opencode/opencode.json ]; then
    cp "$PROJECT_ROOT/config/opencode/opencode.json" ~/.config/opencode/
    echo -e "${GREEN}📋 OpenCode configuration copied to ~/.config/opencode/${NC}"
else
    echo -e "${YELLOW}⚠️  OpenCode configuration already exists${NC}"
    echo "Backup existing and replace with new config? (y/N)"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        cp ~/.config/opencode/opencode.json ~/.config/opencode/opencode.json.backup
        cp "$PROJECT_ROOT/config/opencode/opencode.json" ~/.config/opencode/
        echo -e "${GREEN}📋 Configuration updated (backup saved)${NC}"
    fi
fi

# Copy TUI configuration
if [ ! -f ~/.config/opencode/tui.json ]; then
    cp "$PROJECT_ROOT/config/opencode/tui.json" ~/.config/opencode/
    echo -e "${GREEN}🎨 TUI configuration copied${NC}"
fi

# Create development-specific config
cat > ~/.config/opencode/opencode-dev.json << 'EOF'
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

# Test installation
echo -e "${BLUE}🧪 Testing OpenCode installation...${NC}"
if opencode --help > /dev/null 2>&1; then
    echo -e "${GREEN}✅ OpenCode is working correctly${NC}"
else
    echo -e "${YELLOW}⚠️  OpenCode test failed - may need to restart terminal${NC}"
fi

echo ""
echo -e "${GREEN}🎯 OpenCode setup complete!${NC}"
echo ""
echo -e "${BLUE}📍 Next steps:${NC}"
echo "   1. Restart your terminal or run: source ~/.bashrc"
echo "   2. Test with: opencode --version"
echo "   3. Start coding: opencode"
echo ""
echo -e "${BLUE}💡 Configuration files:${NC}"
echo "   • Main config: ~/.config/opencode/opencode.json"
echo "   • TUI config: ~/.config/opencode/tui.json"
echo "   • Dev config: ~/.config/opencode/opencode-dev.json"
echo ""
echo -e "${BLUE}🚀 Usage examples:${NC}"
echo '   • opencode "Explain this code" --file main.py'
echo '   • opencode "Generate a REST API in Go"'
echo '   • opencode "Review this code for issues" --file src/handlers.go'
echo ""
echo -e "${BLUE}💰 Commercial Freedom:${NC}"
echo "   • MIT License - No commercial restrictions!"
echo "   • Use freely in your company and products"
echo "   • Build and sell applications using OpenCode"