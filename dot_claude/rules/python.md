---
paths:
  - "**/*.py"
  - "**/pyproject.toml"
  - "**/requirements*.txt"
  - "**/setup.py"
---

# Python

## Code Style

- Use uv for everything: `uv run`, `uv pip`, `uv venv`
- Avoid in-line imports unless necessary or adds value
- Avoid excessive try-catch blocks
- Don't catch base Exceptions for normal error handling

## Related

- [error-handling.md](error-handling.md) - Error handling patterns
- [testing.md](testing.md) - Testing philosophy
