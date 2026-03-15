# OpenCode/Crush Integration

> **Complete integration guide for terminal-based AI assistance**

## Overview

Crush is the successor to OpenCode, providing powerful terminal-based AI assistance with direct integration to your local Ollama models.

## Features

- 🔌 **Direct Ollama Integration** - Connect to your local AI models
- 🧠 **Multiple Model Support** - Switch between coding and research models
- 📝 **LSP Integration** - Context-aware assistance with language servers
- 🎯 **Agent System** - Specialized agents for different tasks
- ⚡ **File Context** - AI understands your codebase structure

## Installation

Crush is automatically installed during system setup. To verify:

```bash
crush --version
```

If not installed, run:
```bash
./scripts/install/install-crush.sh
```

## Configuration

Configuration is automatically set up at `~/.config/crush/crush.json` with optimal settings for your local models.

### Available Models

- **qwen2.5-coder:14b** - Primary coding assistant (complex tasks)
- **qwen2.5-coder:7b** - Fast coding assistant (quick tasks)  
- **llama3.1:8b** - Research and documentation (128K context)

### Agent Configuration

- **coder** - Code generation and debugging
- **research** - Documentation and analysis
- **task** - Quick development tasks
- **title** - Generate concise summaries

## Usage Examples

### Basic AI Assistance

```bash
# Start interactive session
crush

# Direct prompts
crush "Explain how to optimize this Python function" --file main.py
crush "Generate a REST API in Go for user management"
```

### Development Workflows

#### Code Review
```bash
# Review current changes
git diff | crush "Review these changes for potential issues"

# Review specific file
crush "Analyze this code for performance improvements" --file database.py
```

#### Documentation
```bash
# Generate function docs
crush "Generate comprehensive documentation for this function" --file utils.py

# Create project README
crush "Generate a README.md for this project based on the codebase"
```

#### Debugging
```bash
# Analyze error logs
crush "Help debug this error" --stdin < error.log

# Debug specific code
crush "Why is this function not working as expected?" --file buggy_code.py
```

### Advanced Usage

#### Custom Agents
```bash
# Use specific agent
crush --agent coder "Generate a database migration"
crush --agent research "Summarize this research paper" --file paper.pdf
```

#### Model Selection
```bash
# Use specific model
crush --model qwen2.5-coder:7b "Quick code fix needed"
crush --model llama3.1:8b "Analyze this long document" --file report.md
```

## IDE Integration

### VS Code
Add to `.vscode/tasks.json`:
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "AI Code Review",
            "type": "shell",
            "command": "crush",
            "args": ["Review this code for potential issues", "--file", "${file}"]
        }
    ]
}
```

### Vim
Add to `.vimrc`:
```vim
function! AskAI()
    let l:prompt = input("AI Prompt: ")
    let l:filename = expand('%')
    execute '!crush "' . l:prompt . '" --file ' . l:filename
endfunction

nnoremap <leader>ai :call AskAI()<CR>
```

## Performance Tips

1. **Keep Models Loaded** - Models stay in memory for 24h
2. **Use Appropriate Models** - qwen2.5-coder:7b for quick tasks
3. **Batch Operations** - Process multiple files in one session
4. **Context Awareness** - Use `--file` flag for better results

## Troubleshooting

See [main troubleshooting guide](../TROUBLESHOOTING.md) for common issues and solutions.

Happy coding with AI! 🚀