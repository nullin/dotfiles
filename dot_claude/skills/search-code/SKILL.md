---
name: search-code
description: Search Sourcegraph-indexed codebases for implementation patterns, code examples, and system understanding. Use when implementing new features, debugging issues, understanding unfamiliar code, or finding how something was done before. Triggers on questions about existing code, patterns, or "how does X work" queries.
---

# Searching Sourcegraph

Search before you build. Existing patterns reduce tokens, ensure consistency, and surface tested solutions.

## Tool Selection

| Goal | Tool |
|------|------|
| Concepts/semantic search | `sg_nls_search` |
| Exact code patterns | `sg_keyword_search` |
| Trace usage | `sg_find_references` |
| See implementation | `sg_go_to_definition` |
| Understand systems | `sg_deepsearch_read` |
| Read files | `sg_read_file` |
| Browse structure | `sg_list_files` |
| Find repos | `sg_list_repos` |
| Search commits | `sg_commit_search` |
| Track changes | `sg_diff_search` |
| Compare versions | `sg_compare_revisions` |

## Scoping Queries

Always constrain searches:

```
repo:^github.com/ORG/REPO$           # Exact repo
repo:github.com/ORG/                 # All repos in org
file:.*\.ts$                         # TypeScript only
file:src/api/                        # Specific directory
file:.*\.test\.ts$ -file:__mocks__   # Tests, exclude mocks
```

Combine filters: `repo:^github.com/myorg/backend$ file:src/handlers lang:typescript`

## Search Types

**Semantic** (`sg_nls_search`) — know the concept, not the code:
- "error handling for API requests"
- "user authentication flow"

**Keyword** (`sg_keyword_search`) — know exact terms:
- `export async function create`
- `app.post('/api/v2`

**Deep Search** (`sg_deepsearch_read`) — need understanding, not just locations:
- "How does billing calculate prorated charges?"
- "Trace flow from signup to welcome email"

Use Deep Search for "how" and "why" questions. Use code search for "where" and "find all" queries.

## Workflows

### Implementing a Feature

```
Task Progress:
- [ ] Find similar implementations
- [ ] Read file structure
- [ ] Study a good example
- [ ] Check shared utilities
```

1. `sg_nls_search`: "repo:^github.com/org/repo$ user settings CRUD"
2. `sg_keyword_search`: "repo:^github.com/org/repo$ file:src/features/ index.ts"
3. `sg_read_file`: Read a representative example
4. `sg_find_references`: Trace shared utilities

### Understanding Unfamiliar Code

```
Task Progress:
- [ ] Get big picture via Deep Search
- [ ] Find entry points
- [ ] Trace implementation
- [ ] Review related tests
```

1. `sg_deepsearch_read`: "How does order fulfillment work?"
2. `sg_keyword_search`: "repo:X file:src/routes export.*order"
3. `sg_go_to_definition`: Jump to main handler
4. `sg_keyword_search`: "repo:X file:.*\.test\.ts describe.*order"

### Debugging an Issue

```
Task Progress:
- [ ] Search for error
- [ ] Find where thrown
- [ ] Understand context
- [ ] Check recent changes
```

1. `sg_keyword_search`: "repo:X 'INVALID_TOKEN_ERROR'"
2. `sg_find_references`: Trace the error symbol
3. `sg_deepsearch_read`: "When is INVALID_TOKEN_ERROR thrown?"
4. `sg_diff_search`: "repo:X INVALID_TOKEN_ERROR"

## Query Patterns

| Intent | Query |
|--------|-------|
| React hooks | `file:.*\.tsx$ use[A-Z].*= \(` |
| API routes | `file:src/api app\.(get\|post\|put\|delete)` |
| Error handling | `catch.*Error\|\.catch\(` |
| Type definitions | `file:types/ export (interface\|type)` |
| Test setup | `file:.*\.test\. beforeEach\|beforeAll` |
| Config files | `file:(webpack\|vite\|rollup)\.config` |
| CI/CD | `file:\.github/workflows deploy` |

## Common Mistakes

| Mistake | Fix |
|---------|-----|
| Searching all repos | Add `repo:^github.com/org/repo$` |
| Too many results | Add `file:` pattern or keywords |
| Missing relevant code | Try `sg_nls_search` for semantic matching |
| Not understanding context | Use `sg_deepsearch_read` |
| Guessing patterns | Read implementations with `sg_read_file` |

## Principles

- Start narrow, expand if needed
- Chain tools: search → read → find references → definition
- Check tests for usage examples
- Read before generating
