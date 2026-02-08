---
allowed-tools: Bash(git *), Edit, Read, AskUserQuestion
description: Interactive code review of branch changes - confirms fixes with user before applying
---

# Claude Branch Review (User Interactive)

Thorough code review of all commits on the current branch compared to main, with user confirmation before making any changes. Unlike the non-interactive version, this skill asks the user to approve each fix before applying it.

## Context

- Working directory: !`pwd`
- Current branch: !`git branch --show-current`
- Base commit: !`git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo "main"`

## Instructions

You are conducting a rigorous code review with user approval for all changes. This ensures the user maintains control over what gets modified.

### Step 1: Assess Scope and Review

Run these commands to understand the branch:

```bash
git log --oneline $BASE_COMMIT..HEAD
git diff --stat $BASE_COMMIT..HEAD
```

**For large branches (>500 lines changed or >10 files):**
Review incrementally:

- Review commit-by-commit: `git show <commit_hash>`
- Or review by file: `git diff $BASE_COMMIT..HEAD -- <filepath>`
- Focus on the most critical/complex files first

**For smaller branches:**

- Review the full diff: `git diff $BASE_COMMIT..HEAD`

Apply the standard review criteria from `../prompts/review-criteria.md`:

1. **Correctness**: Logic errors, off-by-one bugs, incorrect assumptions
2. **Security**: Injection risks, auth gaps, input validation, data exposure
3. **Performance**: Unnecessary allocations, N+1 queries, resource leaks
4. **Error Handling**: Missing error paths, improper propagation, cleanup on failure
5. **Code Quality**: Naming, abstraction level, duplication, style consistency
6. **Edge Cases**: Nil dereferences, empty collections, concurrency, boundaries
7. **Testing**: Testability, obvious missing test cases
8. **Architecture**: Does the overall approach make sense? Are there better patterns?
9. **Commit Hygiene**: Are commits atomic and well-described? Should any be squashed or split?

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

1. Re-run the review on updated code: `git diff $BASE_COMMIT..HEAD`
2. Check if previous issues are resolved
3. Look for any new issues introduced by fixes
4. Present any new issues to the user

**Repeat Steps 2-4 until:**

- No more issues found (APPROVED), OR
- You reach iteration 5 (stop and report remaining issues)

### Step 5: Final Summary

Produce this summary:

```markdown
## Claude Branch Review Summary (User Interactive)

### Branch Info
- Branch: [branch name]
- Commits: [count] commits since main
- Files changed: [count]

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

### Commit Recommendations
[Any suggestions for commit reorganization - squashing, splitting, rewording]

### Remaining Notes
[Any caveats, deferred issues, or recommendations]
```

## Guidelines

- **Always get user approval**: Never make changes without explicit user consent
- **Present clear options**: Use AskUserQuestion with specific, actionable choices
- **Respect user decisions**: If user disagrees, document their reasoning
- **Show your work**: The user should see exactly what was found and what was changed
- **Incremental reviews**: For large branches, review in manageable chunks

## Notes

- This is the interactive version - use `/branch-review` for autonomous fixing
- User maintains full control over which issues to fix
- Re-run git diff after each iteration to see updated state

$ARGUMENTS
