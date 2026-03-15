# Troubleshooting Guide

> **Common issues and solutions for the AI Development Stack**

## 🚨 Quick Fixes

### Most Common Issues

#### 1. Services Won't Start
```bash
# Check if ports are in use
sudo netstat -tulpn | grep -E ':(3001|8081|11434|6380|8787)'

# Kill conflicting processes
sudo fuser -k 3001/tcp 8081/tcp 11434/tcp

# Restart the stack
./scripts/management/stop-stack.sh
./scripts/management/start-stack.sh
```

#### 2. Ollama Not Responding
```bash
# Check Ollama status
systemctl status ollama

# Restart Ollama service
sudo systemctl restart ollama

# Check logs
journalctl -u ollama -f
```

#### 3. Models Not Loading
```bash
# Check available models
ollama list

# Check model size vs available memory
free -h
ollama ps

# Pull missing models
ollama pull qwen2.5-coder:14b
ollama pull llama3.1:8b
```

## 🔍 Diagnostic Commands

### System Health Check

Use the automated health check script:

```bash
./scripts/monitoring/health-check.sh
```

### Manual Diagnostics

#### Check Service Status
```bash
# Ollama service
systemctl status ollama
curl http://localhost:11434/api/version

# Docker containers
docker ps
docker-compose ps

# OpenWebUI
curl -I http://localhost:3001

# SearXNG
curl -I http://localhost:8081

# OpenWork
curl -I http://localhost:8787
```

#### Check Resource Usage
```bash
# Memory usage
free -h
docker stats --no-stream

# Disk space
df -h
du -sh data/

# CPU usage
top -n1 -b | head -20
```

#### Check Logs
```bash
# Ollama logs
journalctl -u ollama --since "1 hour ago"

# Docker container logs
docker logs open-webui
docker logs searxng
docker logs redis
docker logs openwork

# System logs
tail -100 /var/log/syslog
```

## 🐛 Common Issues & Solutions

### Ollama Issues

#### Issue: Ollama Service Fails to Start
```bash
# Symptoms
systemctl status ollama
# Shows: Failed to start Ollama

# Solution 1: Check security settings
sudo nano /etc/systemd/system/ollama.service
# Remove or modify these lines:
# ProtectSystem=strict
# ProtectHome=read-only

# Solution 2: Fix permissions
sudo chown -R ollama:ollama /usr/local/bin/ollama
sudo chmod +x /usr/local/bin/ollama

# Solution 3: Restart systemd
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

#### Issue: Models Won't Download
```bash
# Check disk space
df -h ~/.ollama

# Check network connectivity
curl -I https://ollama.ai

# Manual download with verbose output
OLLAMA_DEBUG=1 ollama pull qwen2.5-coder:14b

# Clear cache if corrupted
rm -rf ~/.ollama/models
ollama pull qwen2.5-coder:14b
```

#### Issue: Out of Memory Errors
```bash
# Check memory usage
ollama ps
free -h

# Solution 1: Stop unused models
ollama stop model-name

# Solution 2: Use smaller models
ollama pull qwen2.5-coder:7b  # Instead of 14b

# Solution 3: Increase swap
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

### Docker Issues

#### Issue: Docker Compose Version Conflicts
```bash
# Symptoms
docker-compose: command not found
# or
ERROR: Version in "./docker-compose.yml" is unsupported

# Solution: Install Docker Compose V2
sudo apt update
sudo apt install docker-compose-plugin

# Or use our wrapper script
./scripts/management/docker-compose-wrapper.sh up -d
```

#### Issue: Permission Denied Errors
```bash
# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Restart Docker service
sudo systemctl restart docker

# Check Docker socket permissions
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
```

#### Issue: Containers Can't Connect to Host
```bash
# Check if host.docker.internal works
docker run --rm alpine ping -c 1 host.docker.internal

# Solution 1: Add host entry to containers
# In docker-compose.yml:
extra_hosts:
  - "host.docker.internal:host-gateway"

# Solution 2: Use host network mode (Linux only)
# In docker-compose.yml:
network_mode: "host"
```

### OpenWebUI Issues

#### Issue: OpenWebUI Shows "No Models Available"
```bash
# Check Ollama connection
curl http://host.docker.internal:11434/api/tags

# Check OpenWebUI environment
docker logs open-webui | grep -i model

# Solution: Update OPENAI_API_BASE_URL
# In docker-compose.yml:
environment:
  - OPENAI_API_BASE_URL=http://host.docker.internal:11434/v1
```

#### Issue: File Uploads Not Working
```bash
# Check OpenWebUI storage permissions
docker exec open-webui ls -la /app/backend/data

# Solution: Fix volume permissions
sudo chown -R 1000:1000 data/open-webui/

# Or recreate container
docker-compose down
docker-compose up -d open-webui
```

#### Issue: RAG Search Not Working
```bash
# Check SearXNG connection
curl http://searxng:8080/search?q=test&format=json

# Check environment variables
docker exec open-webui env | grep SEARX

# Solution: Verify SearXNG URL
# In docker-compose.yml:
environment:
  - SEARXNG_QUERY_URL=http://searxng:8080/search?q=<query>&format=json
```

### SearXNG Issues

#### Issue: SearXNG Returns Empty Results
```bash
# Check SearXNG engines
curl http://localhost:8081/stats

# Check configuration
docker logs searxng | tail -50

# Solution: Update engines configuration
# Edit config/searxng/settings.yml
# Enable working engines:
engines:
  - name: google
    disabled: false
  - name: duckduckgo  
    disabled: false
```

#### Issue: SearXNG Rate Limited
```bash
# Symptoms: "Too Many Requests" errors

# Solution 1: Add delays between requests
# In config/searxng/settings.yml:
outgoing:
  request_timeout: 5.0
  max_request_timeout: 10.0

# Solution 2: Use more search engines
# Enable additional engines to distribute load
```

### OpenWork Issues

#### Issue: OpenWork API Not Accessible
```bash
# Check OpenWork container
docker logs openwork

# Check port binding
docker port openwork

# Solution: Verify port mapping
# In docker-compose.yml:
ports:
  - "8787:8787"
```

#### Issue: Workers Not Connecting to Ollama
```bash
# Check worker configuration
cat config/openwork/workers/ai-development.json

# Test Ollama connection from container
docker exec openwork curl http://host.docker.internal:11434/api/version

# Solution: Update Ollama URL in worker config
{
  "ollama_url": "http://host.docker.internal:11434",
  "model": "qwen2.5-coder:14b"
}
```

### OpenCode Issues

#### Issue: OpenCode Command Not Found
```bash
# Check if OpenCode is installed
which opencode

# Check PATH
echo $PATH | grep -i opencode

# Solution: Reinstall OpenCode
./scripts/install/install-opencode.sh

# Or manually add to PATH
export PATH="$PATH:$HOME/.opencode/bin"
echo 'export PATH="$PATH:$HOME/.opencode/bin"' >> ~/.bashrc
```

#### Issue: OpenCode Can't Connect to Ollama
```bash
# Check OpenCode configuration
cat ~/.opencode/config.json

# Test Ollama connection
curl http://localhost:11434/api/version

# Solution: Update OpenCode config
{
  "api_url": "http://localhost:11434",
  "default_model": "qwen2.5-coder:14b"
}
```

## 🔧 Performance Issues

### Issue: Slow Response Times
```bash
# Check system resources
htop
iotop -ao1

# Check model loading status
ollama ps

# Solutions:
# 1. Preload models
ollama run qwen2.5-coder:14b "test"

# 2. Increase memory
export OLLAMA_MAX_LOADED_MODELS=2
export OLLAMA_KEEP_ALIVE=24h

# 3. Use smaller models
ollama pull qwen2.5-coder:7b
```

### Issue: High Memory Usage
```bash
# Monitor memory usage
watch -n 1 'free -h && echo "=== Docker ===" && docker stats --no-stream'

# Solutions:
# 1. Limit Docker container memory
# In docker-compose.yml:
deploy:
  resources:
    limits:
      memory: 4G

# 2. Configure model keep-alive
export OLLAMA_KEEP_ALIVE=1h  # Shorter time

# 3. Use quantized models
ollama pull qwen2.5-coder:14b-q4_K_M
```

## 🔄 Reset Procedures

### Complete Stack Reset
```bash
# Stop all services
./scripts/management/stop-stack.sh
sudo systemctl stop ollama

# Remove all containers and volumes
docker-compose down -v
docker system prune -af

# Clear Ollama models (optional)
rm -rf ~/.ollama/models

# Restart fresh
sudo systemctl start ollama
./scripts/management/start-stack.sh
```

### Partial Resets

#### Reset OpenWebUI Data
```bash
docker-compose down
sudo rm -rf data/open-webui/
docker-compose up -d open-webui
```

#### Reset SearXNG Cache
```bash
docker-compose restart redis searxng
```

#### Reset OpenWork Configuration
```bash
docker-compose down openwork
sudo rm -rf data/openwork/
docker-compose up -d openwork
```

## 📝 Log Analysis

### Important Log Locations
```bash
# Ollama logs
journalctl -u ollama --since "1 hour ago" -f

# Docker container logs  
docker logs -f open-webui
docker logs -f searxng
docker logs -f openwork

# System logs
tail -f /var/log/syslog | grep -E "(ollama|docker)"

# Application logs
tail -f data/open-webui/logs/webui.log
tail -f data/openwork/logs/server.log
```

### Log Level Adjustments
```bash
# Enable debug mode for detailed logs
# In docker-compose.yml:
environment:
  - LOG_LEVEL=DEBUG
  - OLLAMA_DEBUG=1
  - WEBUI_DEBUG=true
```

## 🆘 Emergency Recovery

### If Everything Fails
```bash
# 1. Save important data
cp -r data/open-webui/uploads ~/backup/
cp -r config/ ~/backup/

# 2. Complete reinstall
git stash  # Save local changes
git pull origin main
chmod +x scripts/install/setup-system.sh
./scripts/install/setup-system.sh

# 3. Restore data
cp -r ~/backup/uploads data/open-webui/
cp -r ~/backup/config .
```

### Get Help
- Check the [GitHub Issues](https://github.com/your-repo/ai-experiments/issues)
- Review the [OpenWebUI Documentation](https://docs.openwebui.com/)
- Consult [Ollama Troubleshooting](https://github.com/ollama/ollama/blob/main/docs/troubleshooting.md)
- Check [Docker Compose Docs](https://docs.docker.com/compose/troubleshooting/)

### Report Bugs
When reporting issues, include:
```bash
# System information
uname -a
docker --version
ollama --version

# Service status
./scripts/monitoring/health-check.sh > health-report.txt

# Recent logs
journalctl -u ollama --since "1 hour ago" > ollama.log
docker logs open-webui > openwebui.log
```

Remember: Most issues can be resolved by restarting services and checking logs. When in doubt, try the complete stack reset procedure!