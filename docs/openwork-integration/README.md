# OpenWork Integration Guide

> Complete automation and workflow management for AI development

## Overview

OpenWork is a powerful automation platform that builds on OpenCode to provide team collaboration, workflow automation, and AI-powered task management. This integration adds enterprise-grade automation capabilities to our AI development stack.

## What is OpenWork?

**OpenWork** is the open-source alternative to Claude Cowork that provides:

- **AI Automation**: Automate repetitive tasks using natural language
- **Team Collaboration**: Share workflows and AI workers across teams  
- **Worker Isolation**: Separate contexts by project or business domain
- **Approval Workflows**: Control dangerous operations with approval gates
- **Browser Automation**: Automate web tasks and data extraction
- **API Integration**: Connect to external services and APIs
- **Scheduled Tasks**: Run workflows on timers and triggers

## Architecture Integration

OpenWork integrates seamlessly with our existing AI stack:

```
┌─────────────┐    ┌──────────────┐    ┌─────────────┐
│ OpenWebUI   │    │ OpenWork     │    │ OpenCode    │
│ Port: 3001  │    │ Port: 8787   │    │ CLI Tool    │
│             │    │              │    │             │
│ • Chat UI   │    │ • Workflows  │    │ • AI Engine │
│ • RAG       │◄──►│ • Automation │◄──►│ • Local LLM │
│ • Models    │    │ • Team Share │    │ • Ollama    │
└─────────────┘    └──────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                  ┌──────────────┐
                  │ SearXNG      │
                  │ Port: 8081   │
                  │              │
                  │ • Web Search │
                  │ • Research   │
                  └──────────────┘
```

## Features

### 🤖 **Pre-configured AI Workers**

Three specialized workers ready for immediate use:

#### 1. **AI Development Worker** (`/openwork/workers/ai-development`)
- **Purpose**: Code generation, debugging, testing, and optimization
- **Model**: Qwen2.5-Coder 14B (primary) + Llama 3.1 8B (fallback)
- **Skills**: Python, JavaScript, Go, Rust, API development, testing
- **Automations**: Code formatting, linting, automated testing
- **Auto-approve**: ✅ Yes (safe operations only)

#### 2. **Data Analysis Worker** (`/openwork/workers/data-analysis`)
- **Purpose**: Data processing, visualization, and statistical analysis
- **Model**: Llama 3.1 8B (primary) + Qwen2.5-Coder 14B (fallback)
- **Skills**: Pandas, NumPy, Matplotlib, data cleaning, reporting
- **Automations**: Data validation, visualization, report generation
- **Auto-approve**: ✅ Yes (analysis operations)

#### 3. **Automation Worker** (`/openwork/workers/automation`)
- **Purpose**: Web scraping, API integration, general automation
- **Model**: Llama 3.1 8B (primary) + Qwen2.5-Coder 14B (fallback)
- **Skills**: Web automation, file processing, system integration
- **Automations**: Web scraping, file processing, notifications
- **Auto-approve**: ❌ No (requires approval for dangerous operations)

### 🔒 **Security & Approvals**

- **Worker Isolation**: Each worker has its own workspace and context
- **Approval Gates**: Dangerous operations require manual approval
- **Rate Limiting**: 100 requests per minute for API protection
- **Audit Logging**: All operations logged for review
- **Token Authentication**: Secure access control for team sharing

### 🌐 **Web Interface**

Access OpenWork's web interface at: **http://localhost:8787/openwork**

- **Worker Management**: Create, configure, and monitor workers
- **Task Queue**: View running and scheduled automations  
- **Team Sharing**: Generate invite links for team members
- **Approval Dashboard**: Review and approve pending operations
- **Audit Logs**: Track all worker activities and changes

## Quick Start

### 1. **Start the Stack**
```bash
./scripts/management/start-stack.sh
```

### 2. **Access OpenWork**
- **Web UI**: http://localhost:8787/openwork
- **API**: http://localhost:8787/api/openwork
- **Health**: http://localhost:80/health

### 3. **Create Your First Automation**

#### Example: Daily Code Review
```javascript
// In the AI Development Worker
"Review all modified files in the current project and create a summary report"

// OpenWork will:
// 1. Scan for changed files (git diff)
// 2. Analyze code quality and issues
// 3. Generate a markdown report
// 4. Save to /workspace/workers/ai-development/reports/
```

#### Example: Data Analysis Pipeline
```python
# In the Data Analysis Worker
"Load sales_data.csv, clean missing values, create visualization, and generate insights report"

# OpenWork will:
# 1. Load and validate the CSV file
# 2. Clean missing/invalid data
# 3. Create charts and graphs
# 4. Generate insights and recommendations
# 5. Export report as HTML/PDF
```

#### Example: Competitive Research (with Approval)
```javascript
// In the Automation Worker (requires approval)
"Scrape competitor pricing from their website and create comparison report"

// OpenWork will:
// 1. Request approval for web scraping
// 2. Wait for manual approval
// 3. Respectfully scrape public data
// 4. Analyze and compare pricing
// 5. Generate competitive intelligence report
```

## Configuration

### **Main Configuration**: `config/openwork/openwork-server.json`
```json
{
  "workspace": {
    "path": "/workspace",
    "approval_mode": "auto",
    "isolation_level": "worker"
  },
  "workers": [
    {
      "name": "ai-development",
      "auto_approve": true,
      "skills": ["code-generation", "debugging", "testing"]
    }
  ],
  "features": {
    "web_ui": true,
    "team_sharing": true,
    "scheduled_tasks": true
  }
}
```

### **Environment Variables**: `.env`
```bash
# OpenWork Authentication
OPENWORK_TOKEN=your-openwork-access-token-here
OPENWORK_HOST_TOKEN=your-openwork-host-token-here
OPENWORK_PORT=8787

# Integration URLs
OPENCODE_URL=http://localhost:11434
```

### **Worker Configuration**: Each worker has its own `opencode.json`
```json
{
  "provider": {
    "type": "ollama",
    "url": "http://ollama:11434",
    "model": "qwen2.5-coder:14b"
  },
  "skills": [
    "python-development",
    "testing-automation",
    "code-review"
  ],
  "automations": {
    "code_formatting": {
      "enabled": true,
      "auto_run": true
    }
  }
}
```

## Team Collaboration

### **Sharing Workers**

1. **Via Web Interface**:
   - Open http://localhost:8787/openwork
   - Select a worker
   - Click "Share" → "Generate Invite Link"
   - Send the link to team members

2. **Manual Setup**:
   - Share worker URL: `http://your-server:8787`
   - Share access token: `your-openwork-access-token`
   - Team members use "Add Worker" → "Connect Remote"

### **Approval Workflows**

For operations requiring approval:

1. Worker submits dangerous operation
2. Operation appears in approval dashboard
3. Admin reviews and approves/rejects
4. Worker continues or stops based on decision

### **Audit & Monitoring**

- **Activity Logs**: `/logs/openwork.log`
- **Worker Status**: Web interface shows all worker states
- **Performance Metrics**: Track automation success rates
- **Resource Usage**: Monitor CPU/memory consumption

## Advanced Usage

### **Custom Skills**

Create custom skills for specific domains:

```json
// config/openwork/workers/custom-worker/opencode.json
{
  "skills": [
    "domain-specific-analysis",
    "custom-api-integration", 
    "specialized-automation"
  ],
  "automations": {
    "custom_workflow": {
      "enabled": true,
      "trigger": "schedule",
      "interval": "daily"
    }
  }
}
```

### **Scheduled Automations**

Set up recurring tasks:

```javascript
// Daily report generation
{
  "name": "daily-metrics-report",
  "schedule": "0 9 * * *",  // 9 AM daily
  "worker": "data-analysis",
  "task": "Generate daily metrics report from database"
}
```

### **API Integration**

Use OpenWork's REST API:

```bash
# List workers
curl http://localhost:8787/api/openwork/workers

# Create task
curl -X POST http://localhost:8787/api/openwork/tasks \
  -H "Authorization: Bearer ${OPENWORK_TOKEN}" \
  -d '{"worker": "ai-development", "task": "Review latest code"}'

# Check task status  
curl http://localhost:8787/api/openwork/tasks/task-id
```

### **Slack/Telegram Integration**

Enable messaging integration with opencode-router:

```bash
# Install router
npm install -g opencode-router

# Configure routing
export SLACK_BOT_TOKEN="xoxb-your-token"
export TELEGRAM_BOT_TOKEN="your-telegram-token"

# Start router
opencode-router start
```

## Troubleshooting

### **Common Issues**

#### OpenWork won't start
```bash
# Check Docker Compose version compatibility
docker compose version

# Check logs
docker logs openwork-server

# Verify configuration
cat config/openwork/openwork-server.json
```

#### Worker not responding
```bash
# Check worker status
curl http://localhost:8787/api/openwork/workers/worker-name

# Restart specific worker
docker compose restart openwork
```

#### Approval not working
- Verify `OPENWORK_HOST_TOKEN` is set correctly
- Check that user has admin permissions
- Review audit logs for approval requests

#### Team sharing fails
- Confirm `OPENWORK_TOKEN` is shared correctly
- Verify network access to server:8787
- Check CORS settings in configuration

### **Performance Optimization**

```json
// Optimize for your workload
{
  "features": {
    "audit_logging": false,  // Disable for performance
    "scheduled_tasks": true
  },
  "security": {
    "rate_limiting": {
      "requests_per_minute": 200  // Increase limit
    }
  }
}
```

### **Monitoring**

```bash
# Check OpenWork health
curl http://localhost:80/health

# View worker performance
./scripts/monitoring/monitor-resources.sh

# Check automation success rates
tail -f /logs/openwork.log | grep "automation_complete"
```

## Integration Benefits

**🚀 Enhanced Productivity**: Automate repetitive development tasks
**👥 Team Scalability**: Share AI workers across multiple team members  
**🔒 Enterprise Security**: Approval workflows and audit logging
**🎯 Specialized Workers**: Purpose-built AI agents for specific domains
**📊 Advanced Analytics**: Detailed automation metrics and reporting
**🌐 Web Integration**: Browser automation for data collection
**⚡ Scheduled Tasks**: Recurring workflows without manual intervention

## Next Steps

1. **Explore Workers**: Try each pre-configured worker type
2. **Create Custom Workers**: Build workers for your specific domains
3. **Set up Team Sharing**: Invite team members to collaborate
4. **Configure Approvals**: Set up approval workflows for sensitive operations
5. **Schedule Automations**: Create recurring tasks for daily workflows
6. **Monitor Performance**: Track automation success and optimize

## Resources

- **OpenWork Documentation**: https://openwork.software/docs
- **OpenCode Integration**: docs/opencode-integration/
- **API Reference**: http://localhost:8787/api/openwork/docs
- **GitHub Repository**: https://github.com/different-ai/openwork

---

**OpenWork transforms your AI development stack from individual AI assistance to enterprise-grade automation platform with team collaboration, workflow management, and intelligent task automation.**