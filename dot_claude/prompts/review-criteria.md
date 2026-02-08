# Code Review Criteria

Standard criteria for all code reviews. This is the single source of truth for review standards.

## Review Categories

Evaluate code against these criteria:

### 1. Correctness
- Logic errors and algorithmic issues
- Off-by-one errors
- Incorrect assumptions about data or state
- Type mismatches or conversion errors
- Boundary condition handling

### 2. Security
- Injection vulnerabilities (SQL, command, XSS, etc.)
- Authentication and authorization gaps
- Input validation and sanitization
- Data exposure or leakage
- Insecure dependencies or configurations
- Secrets in code or logs

### 3. Performance
- Unnecessary allocations or copies
- N+1 query patterns
- Resource leaks (connections, files, memory)
- Inefficient algorithms or data structures
- Missing caching where appropriate
- Blocking operations on critical paths

### 4. Error Handling
- Missing error checks or paths
- Improper error propagation
- Inadequate cleanup on failure
- Silent error swallowing
- Missing validation at boundaries
- Unclear error messages

### 5. Code Quality
- Poor naming (unclear, inconsistent, misleading)
- Inappropriate abstraction level
- Code duplication
- Inconsistent with existing style
- Over-engineering or premature optimization
- Missing or outdated comments (when needed)

### 6. Edge Cases
- Nil/null pointer dereferences
- Empty or single-element collections
- Concurrency issues (race conditions, deadlocks)
- Integer overflow/underflow
- Boundary values (min, max, zero, negative)
- Unexpected state transitions

### 7. Testing
- Untestable code structure
- Missing tests for critical paths
- Missing tests for error conditions
- Obvious test gaps
- Hard-coded test data that could break

### 8. Architecture (Branch Reviews Only)
- Does the overall approach make sense?
- Are there better patterns available?
- Does it fit with existing architecture?
- Are abstractions appropriate?
- Is the design extensible or rigid?

### 9. Commit Hygiene (Branch Reviews Only)
- Are commits atomic and logically grouped?
- Are commit messages clear and descriptive?
- Should any commits be squashed or split?
- Is the git history clean and reviewable?

## Severity Levels

Assign appropriate severity to each issue:

### Critical
- Security vulnerabilities (injection, auth bypass, data exposure)
- Data corruption or loss risks
- Show-stopping bugs that break core functionality
- Issues that could cause system crashes or downtime

### High
- Significant logic errors affecting functionality
- Major performance issues (O(n²) where O(n) possible)
- Broken error handling leading to unclear failures
- Security issues with mitigating factors
- Violations of core architectural principles

### Medium
- Code quality issues affecting maintainability
- Minor performance concerns
- Missing edge case handling
- Style inconsistencies
- Minor testability issues
- Unclear naming or structure

### Low
- Style nitpicks
- Minor improvements possible
- Documentation suggestions
- Nice-to-have refactoring
- Non-critical optimizations

## Output Format

For each issue found, provide:

```
**File:** `path/to/file.ext:line`
**Severity:** Critical | High | Medium | Low
**Category:** [One of the 9 categories above]
**Issue:** [Clear description of the problem]
**Suggestion:** [Specific, actionable fix]
```

Example:

```
**File:** `internal/auth/handler.go:42`
**Severity:** Critical
**Category:** Security
**Issue:** Password comparison using == is vulnerable to timing attacks
**Suggestion:** Use crypto/subtle.ConstantTimeCompare() for password verification
```

## Review Outcome

End your review with one of:

- **APPROVED:** Code is ready to commit/merge
- **APPROVED WITH CAVEATS:** Minor issues noted but not blocking
- **NEEDS REVISION:** Issues must be addressed before proceeding

For "NEEDS REVISION", include issue count by severity:
- Critical: N
- High: N
- Medium: N
- Low: N

## Review Principles

1. **Focus on impact** - Prioritize critical and high severity issues
2. **Be specific** - Provide file:line references and concrete fixes
3. **Explain why** - Help the author understand the issue
4. **Be constructive** - Frame suggestions positively
5. **Consider context** - Understand the broader system before criticizing
6. **Trust but verify** - Check assumptions with code evidence
7. **Recognize good work** - Note well-written code when you see it

## When to Skip Issues

Don't report issues that are:
- Already handled by linters or formatters
- Style preferences without clear benefit
- Hypothetical future problems with no evidence
- Outside the scope of the current change
- Refactorings that don't improve clarity

## Related

- See `../commands/branch-review.md` for full branch review workflow
- See `../commands/diff-review.md` for uncommitted changes review
- See `../rules/grug-brain.md` for simplicity philosophy
- See `../rules/security.md` for security best practices
