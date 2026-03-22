# Codex MCP for Collaborative Planning

Codex MCP provides a collaborative AI partner for planning and problem-solving. Threaded conversations let you think through problems iteratively.

## When to Use Codex

- Planning complex implementations before writing code
- Exploring trade-offs between approaches
- Rubber-ducking problems to find gaps in thinking
- Getting a second opinion on architectural decisions

## Starting a Session

Use `mcp__codex-cli__codex` to start a new conversation:

```
mcp__codex-cli__codex(prompt: "Help me plan the authentication system...")
```

Returns:

```json
{
  "sessionId": "abc123",
  "content": "Response here..."
}
```

## Continuing a Session

Use the same tool with the `sessionId` to continue the conversation:

```
mcp__codex-cli__codex(prompt: "What about JWT vs sessions?", sessionId: "abc123")
```

## Available Tools

- `mcp__codex-cli__codex` - Main tool for coding tasks, questions, and analysis
- `mcp__codex-cli__review` - Code review against current repo (supports base branch, commit, or uncommitted changes)
- `mcp__codex-cli__websearch` - Web search via Codex
- `mcp__codex-cli__listSessions` - List active conversation sessions
- `mcp__codex-cli__help` - Get Codex CLI help info
- `mcp__codex-cli__ping` - Test server connection

## Best Practices

- **Start sessions for planning** - Use codex before diving into implementation
- **Keep sessions focused** - One topic per session for coherent conversations
- **Share context** - Give codex relevant code snippets or requirements
- **Iterate** - Use multiple exchanges to refine ideas before committing to an approach
