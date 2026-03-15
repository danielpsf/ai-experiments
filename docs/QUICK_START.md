# Quick Start Guide

> **Get your AI development stack running in under 5 minutes**

## Prerequisites

- **Linux** (Ubuntu 20.04+ recommended)
- **Docker** and **Docker Compose**
- **32GB+ RAM** (24GB for models + 8GB system)
- **50GB+ storage** available
- **Internet connection** (for initial setup)

## One-Command Setup

```bash
git clone https://github.com/danielpsf/ai-experiments.git
cd ai-experiments
chmod +x scripts/install/setup-system.sh
./scripts/install/setup-system.sh
```

This will:
- ✅ Install Ollama natively for maximum performance
- ✅ Download optimal AI models (Qwen2.5-Coder 14B + Llama 3.1 8B)
- ✅ Configure Docker services (OpenWebUI + SearXNG + Redis)
- ✅ Install OpenCode for terminal AI
- ✅ Set up systemd services for auto-startup
- ✅ Optimize system settings

## Start the Stack

```bash
./scripts/management/start-stack.sh
```

## Access Your AI Environment

- **🌐 OpenWebUI**: http://localhost:3001
- **🔍 SearXNG**: http://localhost:8081  
- **🦙 Ollama API**: http://localhost:11434
- **💻 Terminal AI**: Run `opencode` in any directory

## Quick Health Check

```bash
./scripts/monitoring/health-check.sh
```

## Basic Usage Examples

### Web Interface (OpenWebUI)
1. Open http://localhost:3001
2. Start chatting with your local AI models
3. Upload documents for analysis
4. Use web search integration

### Terminal AI (OpenCode)
```bash
# Code assistance
opencode "Optimize this Python function" --file main.py

# Code generation  
opencode "Create a REST API in Go for user management"

# Code review
opencode "Review this code for security issues" --file auth.py
```

### Direct API Access
```bash
# List available models
curl http://localhost:11434/api/tags

# Chat with a model
curl -X POST http://localhost:11434/api/chat -d '{
  "model": "qwen2.5-coder:14b",
  "messages": [{"role": "user", "content": "Hello"}]
}'
```

## Next Steps

- 📖 [Architecture Overview](ARCHITECTURE.md) - Understanding the system
- ⚙️ [OpenCode Integration](opencode-integration/SETUP.md) - Terminal AI setup
- 🔧 [Performance Tuning](../PERFORMANCE_TUNING.md) - Optimization guide
- 🩺 [Troubleshooting](../TROUBLESHOOTING.md) - Common issues and solutions

## Common Commands

```bash
# Management
./scripts/management/start-stack.sh      # Start all services
./scripts/management/stop-stack.sh       # Stop all services  

# Monitoring
./scripts/monitoring/health-check.sh     # Check system health
./scripts/monitoring/monitor-resources.sh # Monitor resources

# Models
ollama list                              # List installed models
ollama ps                               # Show loaded models
ollama pull qwen2.5-coder:7b            # Download additional models
```

That's it! Your local AI development environment is ready! 🚀