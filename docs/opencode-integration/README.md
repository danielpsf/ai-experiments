# OpenCode Integration

> **Complete guide to using OpenCode.ai terminal AI assistant with your local Ollama models**

## Overview

OpenCode is a powerful MIT-licensed terminal-based AI assistant that provides seamless integration with your local development environment. With commercial-freedom licensing and deep LSP integration, OpenCode offers professional-grade AI assistance without restrictions.

## Key Features

- **MIT License**: Complete commercial freedom - use in any project, company, or product
- **Local Privacy**: All processing happens on your machine with local Ollama models
- **LSP Integration**: Automatic language server protocol support for enhanced code understanding
- **Multiple Agents**: Specialized agents for different tasks (coding, research, quick tasks)
- **Session Management**: Maintain context across development sessions
- **File Context**: Analyze and edit files directly in your project

## Installation

OpenCode is automatically installed during system setup. To verify:

```bash
opencode --version
```

Or install manually:
```bash
./scripts/install/install-opencode.sh
```

## Configuration

Configuration is automatically set up at `~/.config/opencode/opencode.json` with optimal settings for your local models.

### Model Configuration
Your setup includes these pre-configured models:

- **qwen2.5-coder:14b** - Primary coding model (32K context)
- **qwen2.5-coder:7b** - Quick tasks and small operations (32K context)  
- **llama3.1:8b** - Research and analysis (131K context)

### Agent Configuration
Specialized agents are configured for different tasks:

- **coder** - Main coding agent using qwen2.5-coder:14b
- **research** - Analysis and documentation using llama3.1:8b
- **task** - Quick operations using qwen2.5-coder:7b
- **title** - Session title generation using llama3.1:8b

## Basic Usage

### Start OpenCode
```bash
opencode
```

### Code Assistance
```bash
opencode "Explain how to optimize this Python function" --file main.py
opencode "Generate a REST API in Go for user management"
```

### Code Review and Analysis
```bash
# Review changes for issues
git diff | opencode "Review these changes for potential issues"

# Analyze code performance
opencode "Analyze this code for performance improvements" --file database.py
```

### Documentation Generation
```bash
# Generate function documentation
opencode "Generate comprehensive documentation for this function" --file utils.py

# Generate project documentation
opencode "Generate a README.md for this project based on the codebase"
```

### Debugging Assistance
```bash
# Debug errors
opencode "Help debug this error" --stdin < error.log

# Troubleshoot issues  
opencode "Why is this function not working as expected?" --file buggy_code.py
```

## Advanced Features

### Agent Selection
```bash
# Use specific agents for different tasks
opencode --agent coder "Generate a database migration"
opencode --agent research "Summarize this research paper" --file paper.pdf
```

### Model Selection
```bash
# Choose specific models based on task requirements
opencode --model qwen2.5-coder:7b "Quick code fix needed"
opencode --model llama3.1:8b "Analyze this long document" --file report.md
```

## Editor Integration

### Visual Studio Code
Add to your VS Code tasks.json:
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "OpenCode Assistant",
            "type": "shell",
            "command": "opencode",
            "args": ["${input:prompt}", "--file", "${file}"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always"
            }
        }
    ],
    "inputs": [
        {
            "id": "prompt",
            "description": "What would you like OpenCode to do?",
            "type": "promptString"
        }
    ]
}
```

### Vim/Neovim
Add to your vimrc:
```vim
function! OpenCodeAssist()
    let l:prompt = input('OpenCode prompt: ')
    let l:filename = expand('%:p')
    execute '!opencode "' . l:prompt . '" --file ' . l:filename
endfunction

command! OpenCode call OpenCodeAssist()
nnoremap <leader>ai :OpenCode<CR>
```

## LSP Integration

OpenCode automatically detects and uses Language Server Protocol servers for enhanced code understanding:

### Supported Languages
- **Go**: gopls
- **TypeScript/JavaScript**: typescript-language-server
- **Python**: pylsp (Python LSP Server)
- **Rust**: rust-analyzer
- **Java**: Eclipse JDT Language Server

### Custom LSP Configuration
Add custom LSP servers in `~/.config/opencode/opencode.json`:
```json
{
  "lsp": {
    "mylang": {
      "command": "mylang-lsp",
      "args": ["--stdio"],
      "env": {
        "MYLANG_ENV": "development"
      }
    }
  }
}
```

## Configuration Customization

### Model Settings
Customize model behavior in `~/.config/opencode/opencode.json`:
```json
{
  "model": "qwen2.5-coder:14b",
  "small_model": "qwen2.5-coder:7b",
  "agent": {
    "coder": {
      "model": "qwen2.5-coder:14b",
      "description": "Primary coding assistant"
    }
  }
}
```

### Tool Permissions
Configure which tools OpenCode can use:
```json
{
  "permission": {
    "bash": "allow",
    "edit": "allow",
    "write": "ask"
  }
}
```

### UI Customization
Customize the terminal interface in `~/.config/opencode/tui.json`:
```json
{
  "theme": "default",
  "scroll_speed": 3,
  "compact_mode": false
}
```

## Commercial Use

**🎉 Complete Commercial Freedom!**

OpenCode uses the MIT License, which means:
- ✅ **No restrictions** for commercial use
- ✅ **Use in proprietary software** without limitations  
- ✅ **Sell products** that include or use OpenCode
- ✅ **Company usage** without licensing concerns
- ✅ **Modify and distribute** as needed

Unlike other AI tools with commercial restrictions, OpenCode provides complete freedom for business use.

## Troubleshooting

### Common Issues

1. **OpenCode not found**
   ```bash
   # Restart terminal or reload shell
   source ~/.bashrc
   # Or reinstall
   ./scripts/install/install-opencode.sh
   ```

2. **Model connection issues**
   ```bash
   # Check Ollama is running
   ollama list
   # Restart Ollama if needed
   systemctl restart ollama
   ```

3. **LSP not working**
   ```bash
   # Check LSP server is installed
   which gopls typescript-language-server pylsp
   ```

### Debug Mode
Enable debug logging:
```json
{
  "options": {
    "debug": true
  }
}
```

## Performance Optimization

### Memory Management
- **qwen2.5-coder:14b**: ~14GB RAM
- **qwen2.5-coder:7b**: ~7GB RAM  
- **llama3.1:8b**: ~8GB RAM

### Context Management
- Use appropriate models for task complexity
- qwen2.5-coder:7b for quick tasks
- qwen2.5-coder:14b for complex coding
- llama3.1:8b for large document analysis

### Session Optimization
- Keep sessions focused on specific tasks
- Use `/reset` to clear context when switching tasks
- Save important sessions with `/share` for later reference

## Integration with Development Workflow

### Git Workflow
```bash
# Review changes before commit
git diff --cached | opencode "Review these staged changes"

# Generate commit messages
git diff --cached | opencode "Generate a semantic commit message"

# Code review assistance
opencode "Review this pull request for issues" --file changes.diff
```

### CI/CD Integration
OpenCode can be integrated into CI/CD pipelines for:
- Automated code review
- Documentation generation
- Test case creation
- Security analysis

### Project Documentation
```bash
# Generate project documentation
opencode "Create comprehensive API documentation" --file api/routes.js
opencode "Generate setup instructions for this project"
opencode "Create troubleshooting guide based on common issues"
```

## Best Practices

1. **Use Specific Prompts**: Be clear and specific about what you want OpenCode to do
2. **Provide Context**: Use `--file` to give OpenCode access to relevant files
3. **Choose Right Agent**: Use appropriate agents for different types of tasks
4. **Model Selection**: Pick models based on complexity and context requirements
5. **Session Management**: Keep sessions focused and reset when changing topics

## Support and Resources

- **Documentation**: https://opencode.ai/docs
- **GitHub**: https://github.com/anomalyco/opencode
- **Discord**: https://opencode.ai/discord
- **Local Configuration**: `~/.config/opencode/`

OpenCode provides a powerful, commercially-free AI assistant that integrates seamlessly with your development environment while respecting your privacy and giving you complete control over your data and usage.