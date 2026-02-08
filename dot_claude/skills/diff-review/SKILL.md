---
allowed-tools: Bash(git *), Edit, Read
description: Thorough code review of active git changes using iterative Claude collaboration
---

# Claude Diff Review

Thorough code review of active git changes (staged and unstaged). Iterate until the changes are approved or you reach 5 review iterations.

## Context

- Working directory: !`pwd`
- Current branch: !`git branch --show-current`
- Git status: !`git status --short`

## Instructions

You are conducting a rigorous code review of uncommitted changes. Iterate until the changes are approved or you reach 5 review iterations.

### Step 1: Assess Scope

Run these commands to understand the changes:

```bash
git status --short
git diff --stat
git diff --cached --stat
```

Determine the size of the changes:
- **Small**: <10 files or <500 lines changed
- **Large**: >10 files or >500 lines changed

### Step 2: Gather and Review Code

**For large diffs:**
Review incrementally to avoid overwhelming context:
- Review by file: `git diff HEAD -- <filepath>`
- Focus on the most critical/complex files first

**For smaller diffs:**
- Review all uncommitted changes: `git diff HEAD`

### Step 3: Apply Review Criteria

Apply the standard review criteria from `../prompts/review-criteria.md` (focusing on categories 1-7 for uncommitted changes):

1. **Correctness**: Logic errors, off-by-one bugs, incorrect assumptions
2. **Security**: Injection risks, auth gaps, input validation, data exposure
3. **Performance**: Unnecessary allocations, N+1 queries, resource leaks
4. **Error Handling**: Missing error paths, improper propagation, cleanup on failure
5. **Code Quality**: Naming, abstraction level, duplication, style consistency
6. **Edge Cases**: Nil dereferences, empty collections, concurrency, boundaries
7. **Testing**: Testability, obvious missing test cases

See the criteria file for detailed explanations, severity levels, and output format.

### Step 4: Document Issues

For each issue found, document:
- File: path and line number
- Severity: Critical / High / Medium / Low
- Category: Which criteria it violates
- Issue: Clear description
- Suggestion: Specific fix

### Step 5: Get User Approval for Fixes

If no issues found: skip to Step 7 (Final Summary).

If issues found:

1. Present all issues to the user, categorized by severity
2. **Before applying fixes, get user confirmation:**
   - List all Critical/High issues that you recommend fixing
   - List all Medium/Low issues that you recommend fixing
   - Briefly explain the proposed fix for each
   - Ask: "Should I proceed with applying these fixes? (yes/no)"
   - **Only proceed if user explicitly approves**
3. Document any issues you disagree with or that the user chose not to fix

### Step 6: Apply Fixes and Re-Review

After user approval:

1. Fix the approved issues using the Edit tool
2. Re-run the review on the updated code:
   - Run `git diff HEAD` again
   - Review the updated changes
   - Check if previous issues are resolved
   - Look for any new issues introduced by fixes

**Repeat Steps 5-6 until:**

- No more issues found (APPROVED), OR
- You reach iteration 5 (stop and report remaining issues)

### Step 7: Final Summary

Produce this summary:

```markdown
## Claude Diff Review Summary

### Outcome
[APPROVED / APPROVED WITH CAVEATS / MANUAL REVIEW REQUIRED]

### Review Statistics
- Iterations: [N]
- Issues found: [total]
- Issues fixed: [count]
- Disagreements documented: [count]

### Changes Made During Review
[List each code change made to address review feedback, with file:line references]

### Review Concerns Addressed
[Summarize the main categories of issues Claude identified and how they were resolved]

### Remaining Notes
[Any caveats, deferred issues, documented disagreements, or recommendations]
```

## Guidelines

- **Always re-review after fixes**: Re-run git diff to see updated state after applying fixes
- **Preserve user intent**: Address concerns without changing the fundamental approach
- **Document disagreements**: If you think an issue is a false positive, explain why in the summary
- **Show your work**: The user should see exactly what changed and why
- **Incremental reviews**: For large diffs, review in manageable chunks to avoid overwhelming context
- **Focus on critical issues first**: Address security and correctness issues before style

## Notes

- Run git commands directly to gather diffs - don't embed large diffs in context
- Keep iterations focused - fix related issues together
- This reviews uncommitted changes - use `/branch-review` for full branch reviews

$ARGUMENTS
