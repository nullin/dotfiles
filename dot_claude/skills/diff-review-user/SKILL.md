---
allowed-tools: Bash(git *), Edit, Read, AskUserQuestion
description: Interactive code review of uncommitted changes - confirms fixes with user before applying
---

# Claude Diff Review (User Interactive)

Thorough code review of active git changes (staged and unstaged), with user confirmation before making any changes. Unlike the non-interactive version, this skill asks the user to approve each fix before applying it.

## Context

- Working directory: !`pwd`
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`

## Instructions

You are conducting a rigorous code review of uncommitted changes with user approval for all fixes. This ensures the user maintains control over what gets modified.

### Step 1: Assess Scope and Review

Run these commands to understand the changes:

```bash
git status --short
git diff --stat
git diff --cached --stat
```

**For large diffs (>500 lines changed or >10 files):**
Review incrementally:
- Review by file: `git diff HEAD -- <filepath>`
- Focus on the most critical/complex files first

**For smaller diffs:**
- Review all uncommitted changes: `git diff HEAD`

Apply the standard review criteria from `../prompts/review-criteria.md` (focusing on categories 1-7 for uncommitted changes):

1. **Correctness**: Logic errors, off-by-one bugs, incorrect assumptions
2. **Security**: Injection risks, auth gaps, input validation, data exposure
3. **Performance**: Unnecessary allocations, N+1 queries, resource leaks
4. **Error Handling**: Missing error paths, improper propagation, cleanup on failure
5. **Code Quality**: Naming, abstraction level, duplication, style consistency
6. **Edge Cases**: Nil dereferences, empty collections, concurrency, boundaries
7. **Testing**: Testability, obvious missing test cases

See the criteria file for detailed explanations, severity levels, and output format.

### Step 2: Present Issues to User

If no issues found: skip to Step 5 (Final Summary).

If issues found, present them to the user using AskUserQuestion. Group issues by severity and let the user decide what to do.

**For each Critical/High issue, ask:**

```yaml
questions:
  - question: "[Issue description from Claude] - How should we handle this?"
    header: "[Severity]"
    options:
      - label: "Fix it"
        description: "Apply the suggested fix: [brief fix description]"
      - label: "Disagree"
        description: "I disagree with this finding - document why and skip"
      - label: "Defer"
        description: "Valid issue but fix later - note it in summary"
    multiSelect: false
```

**For Medium/Low issues, batch them:**

```yaml
questions:
  - question: "Claude found [N] medium/low severity issues. Which should we address now?"
    header: "Minor Issues"
    options:
      - label: "Fix all"
        description: "Apply all suggested fixes for medium/low issues"
      - label: "Review individually"
        description: "Let me decide on each issue separately"
      - label: "Skip all"
        description: "Note them in summary but don't fix now"
    multiSelect: false
```

### Step 3: Apply Approved Fixes

For each issue the user approved:

1. Use the Edit tool to apply the fix
2. Document what was changed

For disagreements, document the user's reasoning for the re-review.

### Step 4: Re-Review Loop

After making fixes:

1. Re-run the review on updated code: `git diff HEAD`
2. Check if previous issues are resolved
3. Look for any new issues introduced by fixes
4. Present any new issues to the user

**Repeat Steps 2-4 until:**

- No more issues found (APPROVED), OR
- You reach iteration 5 (stop and report remaining issues)

### Step 5: Final Summary

Produce this summary:

```markdown
## Claude Diff Review Summary (User Interactive)

### Outcome
[APPROVED / APPROVED WITH CAVEATS / MANUAL REVIEW REQUIRED]

### Review Statistics
- Iterations: [N]
- Issues found: [total]
- Issues fixed (user approved): [count]
- Issues disagreed (user decision): [count]
- Issues deferred: [count]

### Changes Made During Review
[List each code change made, noting user approval]

### User Decisions
[Document each disagreement or deferral with user's reasoning]

### Review Concerns Addressed
[Summarize the main categories of issues Claude identified and how they were resolved]

### Remaining Notes
[Any caveats, deferred issues, or recommendations]
```

## Guidelines

- **Always get user approval**: Never make changes without explicit user consent
- **Present clear options**: Use AskUserQuestion with specific, actionable choices
- **Respect user decisions**: If user disagrees, document their reasoning
- **Show your work**: The user should see exactly what was found and what was changed
- **Incremental reviews**: For large diffs, review in manageable chunks

## Notes

- This is the interactive version - use `/diff-review` for autonomous fixing
- User maintains full control over which issues to fix
- Re-run git diff after each iteration to see updated state

$ARGUMENTS
