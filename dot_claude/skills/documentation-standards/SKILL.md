---
name: documentation-standards
description: Use when creating or reviewing documentation, READMEs, ADRs, runbooks, or API docs. Use when checking if documentation meets project standards.
---

# Documentation Standards

## When to Use

- Writing or reviewing README files
- Creating architecture decision records (ADRs)
- Writing API documentation
- Reviewing docs in PRs
- Checking if a project's documentation is complete

For the Diataxis framework (tutorials, how-to guides, reference, explanation), use `/diataxis-documentation` instead.

For code comment standards, see `comments.md` rule (always loaded).

## README Requirements

Every repository must have:

1. **Quick Start** - Get running in < 5 minutes with minimal steps
2. **Installation** - Prerequisites, dependencies, environment setup
3. **Usage** - Common use cases with examples
4. **Development** - How to run tests, build, and contribute

Optional sections: Architecture, API Reference, Troubleshooting, FAQ

## API Documentation

- **REST APIs:** OpenAPI/Swagger specification
- **Code APIs:** Use standard generators (godoc, JSDoc, docstrings)
- Include example requests and responses

## Architecture Documentation

For complex systems:

- **ADRs** in `docs/adr/` - One file per decision, immutable format
- **System diagrams** for complex flows (Mermaid, PlantUML)
- **Runbooks** in `docs/runbooks/` - Deployment, troubleshooting, incident response

## Keeping Docs Current

- Update docs in same PR as code changes
- Test code examples - broken examples are worse than none
- Quarterly review - remove outdated content
- Tag docs with version numbers for supported releases

## Anti-Patterns

- Wall of text without structure
- No examples (show, don't just tell)
- Assuming knowledge without defining terms
- Hidden or undiscoverable docs
- Redundant with code (if code is self-documenting, don't repeat)
