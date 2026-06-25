---
name: codex-mcp
description: Use when planning a complex implementation before coding, weighing trade-offs between approaches, rubber-ducking a problem to find gaps, or wanting a second opinion on an architectural decision. Triggers on "plan with codex", "think through this", "CONSULT Codex", or any reference to collaborative planning.
---

# Codex MCP for Collaborative Planning

Codex MCP provides a collaborative AI partner for planning and problem-solving. Threaded conversations let you think through problems iteratively.

## When to Use Codex

- Planning complex implementations before writing code
- Exploring trade-offs between approaches
- Rubber-ducking problems to find gaps in thinking
- Getting a second opinion on architectural decisions

When one of these fits, actually open a Codex session (below) rather than reasoning through it solo - the value is the independent second model, not just the framing.

## Starting a Thread

Use `mcp__codex-cli__codex` to start a new conversation:

```
mcp__codex-cli__codex(prompt: "Help me plan the authentication system...")
```

Returns:
```json
{
  "sessionId": "019bf5f7-dc9a-7781-8575-c456880b2e2f",
  "content": "Response here..."
}
```

## Continuing a Thread

Use `mcp__codex-cli__codex` again with the returned `sessionId` to continue:

```
mcp__codex-cli__codex(sessionId: "019bf5f7-...", prompt: "What about JWT vs sessions?")
```

## Best Practices

- **Start threads for planning** - Use codex before diving into implementation
- **Keep threads focused** - One topic per thread for coherent conversations
- **Share context** - Give codex relevant code snippets or requirements
- **Iterate** - Use multiple exchanges to refine ideas before committing to an approach
