---
allowed-tools: Bash(git *), Edit, Read
description: Thorough code review of all commits on current branch vs main using Claude
---

# Claude Branch Review

Thorough code review of all commits on the current branch compared to main. Use this command before creating a PR to get a rigorous review of all branch changes.

## Context

- Working directory: !`pwd`
- Current branch: !`git branch --show-current`
- Base commit: !`git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD main 2>/dev/null || echo "main"`

## Instructions

You are conducting a rigorous code review of all changes on this branch. This review covers the entire branch - all commits since diverging from main. Iterate until the code is approved or you reach 5 review iterations.

### Step 1: Assess Scope

Run these commands to understand the branch:

```bash
git log --oneline $BASE_COMMIT..HEAD
git diff --stat $BASE_COMMIT..HEAD
```

Determine the size of the changes:

- **Small**: <10 files or <500 lines changed
- **Large**: >10 files or >500 lines changed

### Step 2: Gather and Review Code

**For large branches:**

Review incrementally to avoid overwhelming context:

- Review commit-by-commit: `git show <commit_hash>`
- Or review by file: `git diff $BASE_COMMIT..HEAD -- <filepath>`
- Focus on the most critical/complex files first

**For smaller branches:**

- Review the full diff: `git diff $BASE_COMMIT..HEAD`

### Step 3: Apply Review Criteria

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

**Note**: After making fixes, you may need to amend the last commit or create a new fixup commit depending on the nature of the changes.

### Step 6: Apply Fixes and Re-Review

After user approval:

1. Fix the approved issues using the Edit tool
2. Re-run the review on the updated code:
   - Run `git diff $BASE_COMMIT..HEAD` again
   - Review the updated changes
   - Check if previous issues are resolved
   - Look for any new issues introduced by fixes

**Repeat Steps 5-6 until:**

- No more issues found (APPROVED), OR
- You reach iteration 5 (stop and report remaining issues)

### Step 7: Final Summary

Produce this summary:

```markdown
## Claude Branch Review Summary

### Branch Info
- Branch: [branch name]
- Commits: [count] commits since main
- Files changed: [count]

### Outcome
[APPROVED / APPROVED WITH CAVEATS / MANUAL REVIEW REQUIRED]

### Review Statistics
- Iterations: [N]
- Issues found: [total]
- Issues fixed: [count]
- Disagreements documented: [count]

### Changes Made During Review
[List each code change made to address review feedback, with file:line references and which commit was affected]

### Review Concerns Addressed
[Summarize the main categories of issues Claude identified and how they were resolved]

### Commit Recommendations
[Any suggestions for commit reorganization - squashing, splitting, rewording]

### Remaining Notes
[Any caveats, deferred issues, documented disagreements, or recommendations]
```

## Guidelines

- **Review the whole branch**: Consider how all commits work together, not just individual changes
- **Always re-review after fixes**: Re-run git diff to see updated state after applying fixes
- **Preserve user intent**: Address concerns without changing the fundamental approach
- **Document disagreements**: If you think an issue is a false positive, explain why in the summary
- **Show your work**: The user should see exactly what changed and why
- **Commit hygiene**: If fixes are made, suggest whether to amend or create fixup commits
- **Incremental reviews**: For large branches, review in manageable chunks to avoid overwhelming context

## Notes

- Run git commands directly to gather diffs - don't embed large diffs in context
- Focus on critical issues first, then address minor issues
- Keep iterations focused - fix related issues together

$ARGUMENTS
