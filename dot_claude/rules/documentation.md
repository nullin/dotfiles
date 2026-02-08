# Documentation Standards

## README.md Requirements

Every repository must have:

1. **Quick Start** - Get running in < 5 minutes with minimal steps
2. **Installation** - Prerequisites, dependencies, environment setup
3. **Usage** - Common use cases with examples
4. **Development** - How to run tests, build, and contribute

Optional sections: Architecture, API Reference, Troubleshooting, FAQ

## Code Comments

Follow [comments.md](comments.md) - explain WHY, not WHAT.

- Comment non-obvious decisions and tradeoffs
- Document public APIs with parameters, returns, errors
- Remove outdated comments immediately
- No commented-out code (delete it, it's in git history)

## API Documentation

- **REST APIs:** OpenAPI/Swagger specification
- **Code APIs:** Use standard generators (godoc, JSDoc, docstrings)
- Include example requests and responses

## Architecture Documentation

For complex systems:

- **ADRs** in `docs/adr/` - One file per decision, immutable format
- **System diagrams** for complex flows (Mermaid, PlantUML)
- **Runbooks** in `docs/runbooks/` - Deployment, troubleshooting, incident response

## Keep Documentation Current

- **Update docs in same PR as code changes** - Reviewer checks doc updates
- **Test code examples** - Examples that don't work are worse than no examples
- **Quarterly review** - Remove outdated content, update examples
- **Version documentation** - Tag docs with version numbers for supported releases

## Documentation Anti-Patterns

Avoid:
- Wall of text without structure
- No examples (show, don't just tell)
- Assuming knowledge without defining terms
- Hidden or undiscoverable docs
- Redundant with code (if code is self-documenting, don't repeat)

## Tools

Use `/diataxis-documentation` skill for comprehensive documentation framework (tutorials, how-to guides, reference, explanation).

## Related

- [grug-brain.md](grug-brain.md) - Keep documentation simple
- [comments.md](comments.md) - Code comment guidelines
