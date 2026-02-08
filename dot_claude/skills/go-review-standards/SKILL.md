---
name: go-review-standards
description: Review Go code changes in PRs for idiomatic Go patterns and best practices based on cw-eng-cli code review standards. Use when reviewing Go PRs, checking Go code quality, or applying Go idioms. Triggers on Go code review, PR review for Go files, or "check Go patterns".
allowed-tools:
  - Bash(git:*)
  - Read
---

# Go Code Review Best Practices

Use this guide when reviewing pull requests that modify Go code. These best practices are derived from code reviews by zachspar and lsiv568 in the cw-eng-cli repository.

For detailed before/after examples of each checklist item, read `references/detailed-patterns.md`.

## Review Checklist

When reviewing Go PRs, check for:

### Constants
- [ ] Standard library constants used instead of magic strings (e.g., `http.MethodGet`)
- [ ] Single-use constants avoided (unless system configuration like paths or timeouts)
- [ ] Package-level constants placed at top of file after imports

### Error Handling
- [ ] Errors handled properly (not ignored without comment)
- [ ] Errors in `defer` blocks handled correctly (checking for expected errors like `os.IsNotExist`)
- [ ] Resources properly cleaned up with `defer`

### Types and Values
- [ ] Small structs returned by value, not pointer
- [ ] Boolean zero values used (not explicitly set to false)
- [ ] Related return values grouped into structs (not multiple strings)

### Design
- [ ] Implementation details properly encapsulated (unexported constants, exported functions)
- [ ] Unnecessary state tracking avoided (derive from existing state instead)
- [ ] Function fields avoided when simple value fields would work
- [ ] Duplicate logic extracted into shared functions

### CLI (Cobra)
- [ ] Mutually exclusive flags marked with `MarkFlagsMutuallyExclusive`
- [ ] Error messages clear and actionable (guide user toward solution)

### Maintenance
- [ ] Code designed for testability (interfaces for external deps)
- [ ] Non-obvious decisions documented with comments
- [ ] Project tools used (`make imports` for import formatting)

## Key Principles

1. **Simplicity over cleverness** - match Grug Brain philosophy, avoid premature abstraction
2. **Encapsulate internals** - don't leak implementation details across package boundaries
3. **Explicit error handling** - every error either handled, logged, or propagated with context
4. **Value semantics by default** - use pointers only when mutation or large size justifies it

## Additional Resources

- [Effective Go](https://golang.org/doc/effective_go)
- [Go Code Review Comments](https://github.com/golang/go/wiki/CodeReviewComments)
- [Uber Go Style Guide](https://github.com/uber-go/guide/blob/master/style.md)
- [Grug Brain Developer](https://grugbrain.dev/)

---

**Maintainers:** Update this document and `references/detailed-patterns.md` as new patterns emerge from code reviews.
**Last Updated:** 2026-03-05
**Derived From:** Code reviews by zachspar, lsiv568, and dsridhar-cw in cw-eng-cli repository

$ARGUMENTS
