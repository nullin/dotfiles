Automatically fix CI failures for the current branch and PR.

## Instructions

This command continuously monitors all CI workflows for the current branch, detects failures, analyzes root causes, and proposes potential fixes. **IMPORTANT: This command NEVER commits or pushes changes automatically. All fixes must be manually reviewed and applied by the user.**

### 1. Get Current Branch and PR

```bash
BRANCH=$(git branch --show-current)
```

Check for associated PR:

```bash
gh pr list --head $BRANCH --json number,url,title
```

### 2. Monitor All Workflows

Get all workflow runs for the current branch:

```bash
gh run list --branch $BRANCH --limit 10 --json databaseId,name,status,conclusion,workflowName
```

Look for:

- Status "in_progress" or "queued" → Wait
- Status "completed" + conclusion "failure" → Fix needed
- Status "completed" + conclusion "success" → Done

### 3. Identify Failures

For each failed workflow:

```bash
gh run view <run-id> --log-failed
```

Analyze the error logs to determine:

- Which step failed (e.g., "Run Tilt CI", "golangci-lint", "Run E2E Tests")
- Error message and stack trace
- Root cause

### 4. Identify Root Cause & Propose Fix Recommendations

Analyze the cause of the failure and propose a fix for the failure, if it appears related to the code base.

**Present your recommendations to the user** - do not apply fixes automatically. If proposing a fix, based on the error type, suggest fixes:

**Tilt CI Errors:**

- Missing resource → Add to Tiltfile
- Namespace not found → Add namespace_create()
- Image build failure → Check ko_build deps
- Resource dependency cycle → Reorder resource_deps

**Linting Errors:**

- gofumpt formatting → Run `make lint-fix`
- Complexity (gocyclo) → Add nolint comment
- Unused variables → Remove or use them

**E2E Test Errors:**

- Resource not found → Check resource naming conventions
- Timeout waiting for resource → Increase timeout or fix controller issue
- Controller not deployed → Add to Tiltfile
- Zone mismatch → Update test to use correct zone

**Build Errors:**

- Missing dependency → Add to go.mod
- Import path error → Check replace directives
- Compilation error → Fix syntax

## Important Notes

- Use `gh` CLI for all GitHub interactions
- Make targeted, minimal fixes (don't change unrelated code)
- Root cause analysis should be descriptive
- Preserve user's work (don't force push or reset)
- Monitor ALL workflows (E2E, Lint, Build, etc.)
- If found, run `make lint` locally before pushing lint fixes

## Workflow Names to Monitor

- All workflows defined in .github/workflows/

## Presenting Recommendations to User

After analysis, present findings in this format:

1. **Root Cause**: [Detailed analysis of what caused the failure]
2. **Recommended Fix**: [Specific code changes or commands to run]
3. **Files to Modify**: [List of files that need changes]
4. **Verification Steps**: [How to verify the fix works]

Ask the user: "Would you like me to apply these changes, or would you prefer to review and apply them manually?"

Only proceed with applying fixes if the user explicitly approves.
