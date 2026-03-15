# Basic Crush Usage Guide

## Quick Start

```bash
# Interactive session
crush

# Direct prompts
crush "Explain this code" --file main.py
crush "Generate a Python class for user management"
```

## Common Development Tasks

### Code Generation
```bash
# Generate function
crush "Create a function to parse JSON with error handling"

# Generate class
crush "Generate a Python class for database connections with pooling"

# Generate API endpoint
crush "Create a FastAPI endpoint for user authentication"
```

### Code Review and Analysis
```bash
# Review specific file
crush "Review this code for potential security issues" --file auth.py

# Analyze performance
crush "Analyze this code for performance bottlenecks" --file slow_function.py

# Check best practices
crush "Review this code for Python best practices" --file utils.py
```

### Documentation
```bash
# Generate docstrings
crush "Add comprehensive docstrings to this code" --file module.py

# Create README
crush "Generate a README.md for this project"

# API documentation
crush "Generate API documentation for these endpoints" --file routes.py
```

### Debugging Help
```bash
# Debug error
crush "Help debug this error" --stdin < error.log

# Explain unexpected behavior
crush "Why is this function returning None?" --file buggy_code.py

# Suggest fixes
crush "How can I fix this performance issue?" --file slow_query.py
```

## Advanced Usage

### Using Different Models
```bash
# Quick tasks with fast model
crush --model qwen2.5-coder:7b "Add error handling to this function" --file utils.py

# Complex tasks with powerful model
crush --model qwen2.5-coder:14b "Refactor this entire module for better architecture" --file large_module.py

# Research tasks with long context
crush --model llama3.1:8b "Summarize this research paper" --file paper.pdf
```

### Agent-Specific Tasks
```bash
# Coding agent for development
crush --agent coder "Implement a binary search algorithm"

# Research agent for documentation
crush --agent research "Explain the benefits of microservices architecture"

# Quick task agent for simple fixes
crush --agent task "Fix this syntax error" --file broken.py
```

### Workflow Integration
```bash
# Git hooks integration
git diff --cached | crush "Review these staged changes for issues"

# CI/CD integration
crush "Generate unit tests for this module" --file src/calculator.py

# Code review automation
for file in $(git diff --name-only); do
    crush "Quick review of changes" --file "$file"
done
```

## Configuration Tips

### Customize Agents
Edit `~/.config/crush/crush.json`:

```json
{
  "agents": {
    "security": {
      "model": "qwen2.5-coder:14b",
      "maxTokens": 4000,
      "temperature": 0.1,
      "systemPrompt": "You are a security expert. Focus on finding vulnerabilities and security best practices."
    }
  }
}
```

### LSP Integration
Ensure language servers are installed:

```bash
# Python
pip install python-lsp-server

# Go  
go install golang.org/x/tools/gopls@latest

# TypeScript
npm install -g typescript-language-server

# Rust
rustup component add rls rust-analysis rust-src
```

## Productivity Tips

1. **Use file context** - Always use `--file` when working with specific files
2. **Chain operations** - Use output from one command as input to another
3. **Create aliases** - Set up shell aliases for common tasks
4. **Batch processing** - Process multiple files in scripts
5. **Model selection** - Use appropriate model for task complexity

## Examples in Action

### Debugging Session
```bash
# 1. Analyze error
crush "What's causing this error?" --file error.log

# 2. Examine code
crush "Find the bug in this function" --file buggy_function.py

# 3. Get fix suggestion
crush "How should I fix this issue?" --file buggy_function.py

# 4. Generate test
crush "Create a test that reproduces this bug" --file buggy_function.py
```

### Code Review Workflow
```bash
# 1. Review changes
git diff | crush "Review these changes for potential issues"

# 2. Check specific concerns
crush "Is this function thread-safe?" --file concurrent_code.py

# 3. Suggest improvements
crush "How can this code be improved?" --file module.py

# 4. Generate documentation
crush "Document the API changes" --file api_routes.py
```

Ready to supercharge your development workflow! 🚀