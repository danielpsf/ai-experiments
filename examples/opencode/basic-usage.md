# OpenCode Basic Usage Guide

## Quick Start

```bash
# Interactive session
opencode

# Direct prompts
opencode "Explain this code" --file main.py
opencode "Generate a Python class for user management"
```

## Commercial Freedom

**🎉 Complete MIT License Freedom!**
- ✅ Use in any commercial project
- ✅ Build and sell software using OpenCode
- ✅ No licensing restrictions for companies
- ✅ Modify and distribute without limitations

## Common Development Tasks

### Code Generation
```bash
# Generate function
opencode "Create a function to parse JSON with error handling"

# Generate class
opencode "Generate a Python class for database connections with pooling"

# Generate API endpoint
opencode "Create a FastAPI endpoint for user authentication"
```

### Code Review and Analysis
```bash
# Review specific file
opencode "Review this code for potential security issues" --file auth.py

# Analyze performance
opencode "Analyze this code for performance bottlenecks" --file slow_function.py

# Check best practices
opencode "Review this code for Python best practices" --file utils.py
```

### Documentation
```bash
# Generate docstrings
opencode "Add comprehensive docstrings to this code" --file module.py

# Create README
opencode "Generate a README.md for this project"

# API documentation
opencode "Generate API documentation for these endpoints" --file routes.py
```

### Debugging and Troubleshooting
```bash
# Debug errors
opencode "Help debug this error" --stdin < error.log

# Troubleshoot functions
opencode "Why is this function returning None?" --file buggy_code.py

# Performance issues
opencode "How can I fix this performance issue?" --file slow_query.py
```

## Agent and Model Selection

### Using Different Agents
```bash
# Coding agent (qwen2.5-coder:14b)
opencode --agent coder "Add error handling to this function" --file utils.py

# Research agent (llama3.1:8b)
opencode --agent research "Summarize this research paper" --file paper.pdf

# Quick task agent (qwen2.5-coder:7b)
opencode --agent task "Fix this syntax error" --file broken.py
```

### Direct Model Selection
```bash
# Fast model for quick tasks
opencode --model qwen2.5-coder:7b "Add error handling to this function" --file utils.py

# Main model for complex refactoring
opencode --model qwen2.5-coder:14b "Refactor this entire module for better architecture" --file large_module.py

# Large context model for document analysis
opencode --model llama3.1:8b "Summarize this research paper" --file paper.pdf
```

## Integration with Git Workflow

### Code Review Pipeline
```bash
# Review staged changes
git diff --cached | opencode "Review these staged changes for issues"

# Generate tests
opencode "Generate unit tests for this module" --file src/calculator.py

# Pre-commit hook integration
for file in $(git diff --cached --name-only); do
    opencode "Quick review of changes" --file "$file"
done
```

## Configuration and Customization

### Default Configuration Location
Edit `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "model": "qwen2.5-coder:14b",
  "small_model": "qwen2.5-coder:7b",
  "agent": {
    "coder": {
      "model": "qwen2.5-coder:14b",
      "description": "Primary coding assistant"
    },
    "research": {
      "model": "llama3.1:8b",
      "description": "Research and analysis"
    },
    "task": {
      "model": "qwen2.5-coder:7b",
      "description": "Quick operations"
    }
  },
  "lsp": {
    "go": {
      "command": "gopls"
    },
    "typescript": {
      "command": "typescript-language-server",
      "args": ["--stdio"]
    },
    "python": {
      "command": "pylsp"
    }
  }
}
```

### Custom TUI Configuration
Edit `~/.config/opencode/tui.json`:

```json
{
  "$schema": "https://opencode.ai/tui.json",
  "theme": "default",
  "scroll_speed": 3,
  "compact_mode": false
}
```

## Advanced Usage Patterns

### Debugging Workflow
```bash
# Step 1: Analyze error
opencode "What's causing this error?" --file error.log

# Step 2: Find the bug
opencode "Find the bug in this function" --file buggy_function.py

# Step 3: Get fix suggestion
opencode "How should I fix this issue?" --file buggy_function.py

# Step 4: Generate test
opencode "Create a test that reproduces this bug" --file buggy_function.py
```

### Code Quality Workflow
```bash
# Security review
git diff | opencode "Review these changes for potential issues"

# Thread safety analysis
opencode "Is this function thread-safe?" --file concurrent_code.py

# General improvement
opencode "How can this code be improved?" --file module.py

# Documentation
opencode "Document the API changes" --file api_routes.py
```

### Refactoring Workflow
```bash
# Analysis phase
opencode "Analyze this code structure and suggest improvements" --file legacy_code.py

# Planning phase
opencode "Create a refactoring plan for this module" --file complex_module.py

# Implementation phase
opencode "Refactor this function to use dependency injection" --file service.py

# Testing phase
opencode "Generate comprehensive tests for this refactored code" --file new_service.py
```

## File Context and LSP Integration

### Using File Context
```bash
# Analyze specific file
opencode "Review this entire file for issues" --file src/main.py

# Cross-file analysis
opencode "How does this function interact with the rest of the codebase?" --file utils.py

# Project-wide changes
opencode "Update all files to use the new API structure" --file api_changes.md
```

### LSP-Enhanced Understanding
OpenCode automatically uses Language Server Protocol servers for:
- **Go**: gopls (Go language server)
- **TypeScript**: typescript-language-server
- **Python**: pylsp (Python LSP Server)
- **Rust**: rust-analyzer
- **Java**: Eclipse JDT Language Server

This provides enhanced code understanding including:
- Type information
- Symbol definitions
- Cross-reference analysis
- Syntax tree understanding

## Performance Optimization

### Model Selection Strategy
- **qwen2.5-coder:7b**: Quick edits, syntax fixes, small functions (~7GB RAM)
- **qwen2.5-coder:14b**: Complex refactoring, architecture decisions (~14GB RAM)
- **llama3.1:8b**: Large document analysis, research tasks (~8GB RAM)

### Session Management
```bash
# Start fresh session for new topic
opencode  # Interactive mode with clean context

# Continue previous session
opencode --session "project-refactoring"

# Save important conversations
opencode --save "debugging-session-2024"
```

### Context Management Tips
1. **Be specific**: Clear prompts get better results
2. **Provide context**: Use `--file` for relevant code
3. **Choose right agent**: Match agent to task complexity
4. **Reset when needed**: Clear context when changing topics

## Troubleshooting

### Common Issues
```bash
# Check installation
opencode --version

# Verify Ollama connection
opencode "test connection"

# Debug mode
export OPENCODE_DEBUG=1
opencode "debug this issue" --file problem.py
```

### Performance Issues
```bash
# Check model status
ollama ps

# Restart Ollama if needed
systemctl restart ollama

# Free up memory
ollama unload qwen2.5-coder:14b
```

## Integration with Editors

### VS Code
Add to tasks.json:
```json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "OpenCode Assistant",
            "type": "shell",
            "command": "opencode",
            "args": ["${input:prompt}", "--file", "${file}"]
        }
    ]
}
```

### Vim/Neovim
Add to .vimrc:
```vim
function! OpenCodeAssist()
    let l:prompt = input('OpenCode: ')
    let l:filename = expand('%:p')
    execute '!opencode "' . l:prompt . '" --file ' . l:filename
endfunction

command! OpenCode call OpenCodeAssist()
nnoremap <leader>ai :OpenCode<CR>
```

## Best Practices

1. **Start with clear objectives**: Be specific about what you want OpenCode to do
2. **Provide relevant context**: Use --file to give OpenCode access to the right files
3. **Choose appropriate models**: Match model complexity to task requirements
4. **Use agents wisely**: Different agents for different types of work
5. **Maintain context**: Keep sessions focused on related tasks
6. **Review suggestions**: Always review and test OpenCode's suggestions
7. **Iterate and improve**: Use follow-up prompts to refine results

## License and Commercial Use

**OpenCode uses the MIT License**, which means:
- ✅ **Commercial use permitted**: Use in any business context
- ✅ **Modify and distribute**: Change the tool as needed
- ✅ **Private use**: Use internally without restrictions
- ✅ **No warranty disclaimers**: Standard MIT license terms apply

This makes OpenCode ideal for:
- **Enterprise development**: No licensing restrictions
- **Startup projects**: Use without legal concerns
- **Commercial products**: Include in products you sell
- **Consulting work**: Use for client projects freely

OpenCode provides professional-grade AI assistance with complete commercial freedom!