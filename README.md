# AI Development Stack Experiments

> **A comprehensive local AI development environment with OpenWebUI, Ollama, SearXNG, OpenCode, and OpenWork automation platform**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-ready-blue.svg)](https://www.docker.com/)
[![Ollama](https://img.shields.io/badge/Ollama-compatible-green.svg)](https://ollama.ai/)

## 🚀 Quick Start

Get your AI development stack running in under 5 minutes:

```bash
git clone https://github.com/danielpsf/ai-experiments.git
cd ai-experiments
chmod +x scripts/install/setup-system.sh
./scripts/install/setup-system.sh
./scripts/management/start-stack.sh
```

**Access Points:**
- 🌐 **OpenWebUI**: http://localhost:3001 (Main AI interface)
- 🔍 **SearXNG**: http://localhost:8081 (Privacy-focused search)
- 🤖 **OpenWork**: http://localhost:8787 (AI automation & workflows)
- 🦙 **Ollama API**: http://localhost:11434 (Direct model access)
- 🤖 **OpenCode**: Terminal-based AI assistant

## ✨ Features

### 🏗️ Hybrid Architecture
- **Native Ollama**: Maximum performance for AI models
- **Containerized Services**: Easy deployment and management
- **Single-User Optimized**: No authentication overhead

### 🧠 AI Models
- **Qwen2.5-Coder 14B**: State-of-the-art coding assistance
- **Llama 3.1 8B**: Research and general purpose (128K context)
- **Quick Model Switching**: Hot-swap models without restart

### 🔍 Research Capabilities
- **SearXNG Integration**: Privacy-focused web search
- **RAG Support**: Document analysis and Q&A
- **Long Context**: Handle entire codebases and research papers

### 💻 Development Tools
- **OpenCode**: Terminal AI assistant
- **LSP Integration**: Language server support
- **API Access**: Full REST API compatibility

### 🔄 Automation & Workflows (NEW!)
- **OpenWork Platform**: Enterprise-grade AI automation
- **Pre-configured Workers**: AI development, data analysis, automation
- **Team Collaboration**: Share workflows across team members
- **Approval Workflows**: Control dangerous operations
- **Browser Automation**: Automated web scraping and data extraction
- **Scheduled Tasks**: Recurring workflows and reports

## 📚 Documentation

- 📖 [Quick Start Guide](docs/QUICK_START.md) - Get running in 5 minutes
- 🏗️ [Architecture Overview](docs/ARCHITECTURE.md) - System design and components
- ⚙️ [OpenCode Integration](docs/opencode-integration/README.md) - Terminal AI setup
- 🤖 [OpenWork Automation](docs/openwork-integration/README.md) - AI workflows & team collaboration
- 🔧 [Performance Tuning](docs/PERFORMANCE_TUNING.md) - Optimization guide
- 🩺 [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and solutions

## 🎯 Use Cases

### For Developers
- **Code Generation**: AI-powered code completion and generation
- **Code Review**: Automated code analysis and suggestions
- **Documentation**: Generate and improve code documentation
- **Debugging**: AI-assisted debugging and error analysis

### For Researchers
- **Document Analysis**: Process and analyze research papers
- **Web Research**: Privacy-focused information gathering
- **Data Processing**: AI-powered data analysis workflows
- **Writing Assistance**: Academic and technical writing support

### For Teams & Automation
- **Workflow Automation**: Automate repetitive business processes
- **Data Collection**: Automated web scraping and data gathering
- **Report Generation**: Scheduled analytics and insights reports
- **Code Automation**: Automated testing, deployment, and monitoring
- **Team Collaboration**: Share AI workers and workflows across teams

## 📊 System Requirements

- **OS**: Linux (Ubuntu 20.04+ recommended)
- **RAM**: 32GB+ (24GB for models + 8GB for system)
- **CPU**: 8+ cores recommended
- **Storage**: 50GB+ available space
- **Network**: Internet connection for initial setup

## 🔧 Services Overview

| Service | Port | Purpose | Resource Usage |
|---------|------|---------|----------------|
| OpenWebUI | 3001 | Main AI interface | ~1-2GB RAM |
| SearXNG | 8081 | Privacy search | ~512MB RAM |
| OpenWork | 8787 | AI automation & workflows | ~512MB-1GB RAM |
| Ollama | 11434 | AI model server | ~15-20GB RAM |
| Redis | 6380 | Caching layer | ~512MB RAM |

## 🚀 Quick Commands

```bash
# Start the entire stack
./scripts/management/start-stack.sh

# Check system health
./scripts/monitoring/health-check.sh

# Stop all services
./scripts/management/stop-stack.sh

# View logs
./scripts/monitoring/log-viewer.sh

# Terminal AI assistant
opencode "Help me optimize this Python function" --file main.py
```

## 🤝 Contributing

Contributions are welcome! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OpenWebUI](https://github.com/open-webui/open-webui) - Excellent AI interface
- [Ollama](https://github.com/ollama/ollama) - Local LLM runner
- [SearXNG](https://github.com/searxng/searxng) - Privacy-focused search
- [OpenCode.ai](https://opencode.ai/) - MIT-licensed terminal AI tools

---

**⭐ If you find this project useful, please consider giving it a star!**