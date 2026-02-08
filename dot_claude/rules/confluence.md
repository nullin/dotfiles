# Confluence API

Uses same API token as Jira (stored in `~/.netrc`).

## Critical: Single-Line JSON Commands

```bash
# CORRECT: Single line to avoid permission issues
curl -X POST "..." --netrc -H "Content-Type: application/json" -d '{"key": "value"}'

# WRONG: Newlines may trigger permission errors
curl -X POST "..." --netrc -H "Content-Type: application/json" -d '{
  "key": "value"
}'
```

## Common Space IDs

- Network Datapath (NTWRKDP): 321880319

## Detailed Operations

Use `/cw-confluence` skill for complete API reference including:

- Listing and searching pages
- Reading page content
- Creating and updating pages
- Managing page hierarchies
- Error handling patterns

## Related

- [jira.md](jira.md) - Jira CLI usage (shares same authentication)
