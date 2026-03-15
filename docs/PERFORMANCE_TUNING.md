# Performance Tuning Guide

> **Optimization strategies to maximize performance of your AI Development Stack**

## 🎯 Performance Overview

This guide helps you optimize your AI Development Stack for maximum performance based on your hardware configuration and usage patterns.

## 🚀 Quick Performance Wins

### 1. Model Selection Optimization

Choose models based on your hardware capabilities:

```bash
# For systems with 32GB+ RAM - Use larger models
ollama pull qwen2.5-coder:14b    # Primary coding model
ollama pull llama3.1:8b          # Research and analysis

# For systems with 16-32GB RAM - Use medium models  
ollama pull qwen2.5-coder:7b     # Faster coding model
ollama pull llama3.1:8b          # Research model

# For systems with 8-16GB RAM - Use smaller models
ollama pull qwen2.5-coder:3b     # Lightweight coding
ollama pull llama3.1:8b          # Keep for research
```

### 2. Ollama Environment Optimization

Add these to your `~/.bashrc` or system environment:

```bash
# Memory and Performance Optimization
export OLLAMA_MAX_LOADED_MODELS=2          # Keep 2 models in memory
export OLLAMA_KEEP_ALIVE=24h               # Keep models loaded for 24 hours
export OLLAMA_NUM_PARALLEL=2               # Allow 2 parallel requests
export OLLAMA_FLASH_ATTENTION=1            # Enable flash attention (if supported)
export OLLAMA_CPU_THREADS=8                # Set CPU threads (adjust for your CPU)

# GPU Optimization (if available)
export CUDA_VISIBLE_DEVICES=0              # Use first GPU
export OLLAMA_GPU_OVERHEAD=0               # Minimize GPU overhead
```

### 3. Docker Resource Optimization

Update your `docker-compose.yml` with resource limits:

```yaml
services:
  open-webui:
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
        reservations:
          memory: 2G
          cpus: '1.0'
  
  searxng:
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
  
  redis:
    deploy:
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
        reservations:
          memory: 512M
          cpus: '0.25'
```

## 🔧 System-Level Optimizations

### 1. CPU Governor Settings

Set performance mode for maximum CPU performance:

```bash
# Check current governor
cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Set performance governor (requires root)
sudo cpupower frequency-set -g performance

# Or for Intel systems with intel_pstate
echo performance | sudo tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
```

### 2. Memory Optimization

#### Increase swap for model loading
```bash
# Create 16GB swap file for model loading
sudo fallocate -l 16G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Make permanent
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

#### Optimize memory settings
```bash
# Add to /etc/sysctl.conf
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
echo 'vm.vfs_cache_pressure=50' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_ratio=15' | sudo tee -a /etc/sysctl.conf
echo 'vm.dirty_background_ratio=5' | sudo tee -a /etc/sysctl.conf

# Apply immediately
sudo sysctl -p
```

### 3. I/O Optimization

#### SSD optimization for model storage
```bash
# Add to /etc/fstab for SSD optimization
# /dev/sda1 / ext4 defaults,noatime,discard 0 1

# Enable TRIM for SSDs
sudo systemctl enable fstrim.timer
```

## 🧠 Model-Specific Optimizations

### 1. Model Preloading Strategy

Create a model preload script:

```bash
#!/bin/bash
# scripts/optimization/preload-models.sh

echo "Preloading AI models for optimal performance..."

# Preload primary coding model
ollama run qwen2.5-coder:14b "Hello" > /dev/null 2>&1 &

# Wait and preload research model
sleep 10
ollama run llama3.1:8b "Hello" > /dev/null 2>&1 &

echo "Models preloaded successfully!"
```

### 2. Model Quantization

For memory-constrained systems, use quantized models:

```bash
# Pull quantized versions for better memory efficiency
ollama pull qwen2.5-coder:14b-q4_K_M    # 4-bit quantized
ollama pull llama3.1:8b-q4_K_M          # 4-bit quantized
```

## 🔍 OpenWebUI Performance Tuning

### 1. Database Optimization

OpenWebUI uses SQLite by default. For better performance:

```bash
# Set in environment variables
export OPENWEBUI_DB_URL="sqlite:///data/webui.db?cache=shared&mode=rwc"
export OPENWEBUI_ENABLE_RAG_WEB_SEARCH=true
export OPENWEBUI_RAG_CHUNK_SIZE=1000
export OPENWEBUI_RAG_CHUNK_OVERLAP=100
```

### 2. Disable Unnecessary Features

Add to your `.env` file:

```bash
# Disable features you don't use
ENABLE_LOGIN=false
ENABLE_SIGNUP=false
ENABLE_IMAGE_GENERATION=false
ENABLE_COMMUNITY_SHARING=false
DEFAULT_USER_ROLE=admin
```

## 🔍 SearXNG Performance Optimization

### 1. Engine Selection

Edit `config/searxng/settings.yml`:

```yaml
engines:
  # Keep only fast, reliable engines
  - name: duckduckgo
    disabled: false
    timeout: 3.0
  
  - name: google
    disabled: false
    timeout: 3.0
    
  - name: stackoverflow
    disabled: false
    timeout: 5.0
    
  - name: github
    disabled: false
    timeout: 5.0
    
  # Disable slow engines
  - name: bing_news
    disabled: true
```

### 2. Cache Configuration

Optimize Redis caching for SearXNG:

```yaml
# config/redis/redis.conf
maxmemory 1gb
maxmemory-policy allkeys-lru
save 60 1000
tcp-keepalive 300
```

## 🤖 OpenWork Performance Tuning

### 1. Worker Resource Allocation

Update worker configurations in `config/openwork/workers/`:

```json
{
  "worker_id": "ai-development",
  "model": "qwen2.5-coder:14b",
  "max_parallel_tasks": 2,
  "memory_limit": "8GB",
  "timeout": 300,
  "auto_approve": true,
  "resource_allocation": {
    "cpu_cores": 4,
    "memory_gb": 8,
    "priority": "high"
  }
}
```

### 2. Task Queue Optimization

```json
{
  "queue_settings": {
    "max_queue_size": 100,
    "worker_timeout": 300,
    "retry_attempts": 3,
    "batch_processing": true,
    "priority_scheduling": true
  }
}
```

## 📊 Performance Monitoring

### 1. Resource Monitoring Script

Create `scripts/monitoring/performance-monitor.sh`:

```bash
#!/bin/bash
# Monitor system performance for AI stack

echo "=== AI Stack Performance Monitor ==="
echo "Timestamp: $(date)"
echo

# Check Ollama model status
echo "=== Ollama Models ==="
ollama list

# Check memory usage
echo "=== Memory Usage ==="
free -h

# Check CPU usage
echo "=== CPU Usage ==="
top -bn1 | grep "Cpu(s)"

# Check Docker containers
echo "=== Docker Container Stats ==="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# Check disk usage
echo "=== Disk Usage ==="
df -h | grep -E '^/dev/'

echo "=== GPU Usage (if available) ==="
nvidia-smi 2>/dev/null || echo "No GPU detected"
```

### 2. Performance Benchmarking

Create `scripts/testing/benchmark.sh`:

```bash
#!/bin/bash
# Benchmark AI model performance

echo "Running AI Stack Performance Benchmark..."

# Test Ollama API response time
echo "Testing Ollama API response time..."
time curl -s -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "qwen2.5-coder:14b", "prompt": "Hello", "stream": false}' > /dev/null

# Test OpenWebUI response time
echo "Testing OpenWebUI response time..."
time curl -s http://localhost:3001 > /dev/null

# Test SearXNG response time
echo "Testing SearXNG response time..."
time curl -s "http://localhost:8081/search?q=test&format=json" > /dev/null

echo "Benchmark complete!"
```

## 🐛 Performance Troubleshooting

### Common Performance Issues

#### 1. High Memory Usage
```bash
# Check model memory usage
ollama ps

# Unload unused models
ollama stop model-name
```

#### 2. Slow Model Responses
```bash
# Check if model is quantized (slower)
ollama show qwen2.5-coder:14b --modelfile | grep quant

# Switch to non-quantized version
ollama pull qwen2.5-coder:14b  # Full precision
```

#### 3. Docker Performance Issues
```bash
# Check container resource usage
docker stats

# Restart containers if needed
docker-compose restart
```

### Performance Baseline Expectations

| Hardware Config | Expected Performance | Model Recommendations |
|----------------|---------------------|---------------------|
| 64GB RAM, 12+ cores | 15-25 tokens/sec | qwen2.5-coder:14b + llama3.1:8b |
| 32GB RAM, 8+ cores | 8-15 tokens/sec | qwen2.5-coder:14b + llama3.1:8b |
| 16GB RAM, 4+ cores | 5-10 tokens/sec | qwen2.5-coder:7b + llama3.1:8b |
| 8GB RAM, 4 cores | 2-5 tokens/sec | qwen2.5-coder:3b only |

## 🎛️ Advanced Tuning

### 1. NUMA Optimization (Multi-socket systems)

```bash
# Check NUMA topology
numactl --hardware

# Run Ollama on specific NUMA node
numactl --cpunodebind=0 --membind=0 ollama serve
```

### 2. Custom Model Compilation

For maximum performance, compile models for your specific hardware:

```bash
# This requires advanced setup and is hardware-specific
# Consult Ollama documentation for GGML compilation
```

### 3. Network Optimization

```bash
# Increase network buffer sizes
echo 'net.core.rmem_max = 16777216' | sudo tee -a /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_rmem = 4096 65536 16777216' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_wmem = 4096 65536 16777216' | sudo tee -a /etc/sysctl.conf

sudo sysctl -p
```

Remember to restart services after making configuration changes for optimal performance!