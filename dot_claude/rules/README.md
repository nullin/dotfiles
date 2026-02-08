# Development Rules

This directory contains rules and guidelines that govern code quality, workflow, and tool usage.

## Code Quality & Style

- **[grug-brain.md](grug-brain.md)** - Simplicity philosophy: fight complexity, prefer explicit code
- **[comments.md](comments.md)** - Comment policy: explain why, not what
- **[python.md](python.md)** - Python conventions: use uv, avoid excessive try-catch

## Workflow & Process

- **[aviator.md](aviator.md)** - Aviator CLI for stacked PR workflow and flexible git operations
- **[pr-workflow.md](pr-workflow.md)** - PR workflow standards: use diff as source of truth

## Quality Standards

- **[testing.md](testing.md)** - Testing philosophy: test user-facing behavior, not implementation
- **[error-handling.md](error-handling.md)** - Error handling standards: fail fast, be explicit, provide context
- **[security.md](security.md)** - Security best practices: OWASP Top 10, input validation, secrets management
- **[documentation.md](documentation.md)** - Documentation standards: keep docs close to code, write for future readers

## Tools & Integration

- **[nix.md](nix.md)** - Nix package manager and system configuration: NixOS, nix-darwin, Home Manager, flakes
- **[chezmoi.md](chezmoi.md)** - Dotfile management: templates, encryption, multi-machine configuration
- **[cw-cli.md](cw-cli.md)** - CoreWeave CLI usage: repo creation, scaffolding, dev environment
- **[jira.md](jira.md)** - Jira CLI usage: viewing issues, creating tasks
- **[confluence.md](confluence.md)** - Confluence API usage: reading/updating wiki pages

## Cross-References

Several rules reference each other:

- **grug-brain.md** is referenced by: comments.md, testing.md, python.md, error-handling.md, security.md, documentation.md
- **documentation.md** references: grug-brain.md, comments.md
- **error-handling.md** references: grug-brain.md, security.md, testing.md, documentation.md
- **security.md** references: grug-brain.md, error-handling.md, testing.md

## Quick Decision Guides

### Which rule for my situation?

| Situation | See Rule |
|-----------|----------|
| Writing code comments | comments.md |
| Adding error handling | error-handling.md |
| Writing tests | testing.md |
| Reviewing for security | security.md |
| Creating documentation | documentation.md |
| Using Aviator for stacked PRs | aviator.md |
| Creating a PR | pr-workflow.md |
| Deciding on abstractions | grug-brain.md |
| Python-specific conventions | python.md |
| Managing system with Nix | nix.md |
| Managing dotfiles | chezmoi.md |
| Using CoreWeave CLI | cw-cli.md |
| Working with Jira | jira.md |
| Working with Confluence | confluence.md |

## Philosophy

These rules follow the grug-brain philosophy:
- Simplicity over cleverness
- Explicit over implicit
- Working code over perfect architecture
- Solve today's problems, not hypothetical future ones

See [grug-brain.md](grug-brain.md) for the foundation of these principles.
