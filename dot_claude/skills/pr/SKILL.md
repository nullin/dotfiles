---
name: pr
description: Create a draft pull request with branch safety checks. Use when user says "/pr", "create pr", "create pull request", or wants to open a draft PR.
allowed-tools:
  - Bash(git:*)
  - Bash(gh:*)
  - Read
---

# Create Draft PR

Safely create a draft pull request with proper branch verification.

## Process

1. **Verify branch state**
   - Run `git branch --show-current` to confirm current branch
   - ABORT if on main or master
   - Run `git status` to check for uncommitted changes (warn user if dirty)

2. **Determine target branch**
   - Default target: `main`
   - If user specifies a different target, use that
   - Confirm target with user

3. **Show what will be in the PR**
   - Run `git log --oneline <target>..HEAD` to show commits
   - Run `git diff <target> --stat` to show changed files summary
   - Confirm with user before proceeding

4. **Push branch**
   - Check if branch has a remote tracking ref: `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`
   - If not tracking or behind, push: `git push -u origin $(git branch --show-current)`
   - WAIT for explicit user approval before pushing

5. **Create draft PR**
   - Use `gh pr create --draft --base <target>`
   - Title: derive from branch name or commit subjects, keep under 70 chars
   - Body: use `gh pr diff` as source of truth per pr-workflow rule
   - Format body as: `## Summary` with 1-3 bullet points
   - NO test plan section unless user explicitly requests one

6. **Report**
   - Show the PR URL

## Safety Rules

- NEVER create PR from main or master
- ALWAYS verify current branch before any operation
- ALWAYS get explicit user approval before pushing to remote
- ALWAYS create as draft unless user says otherwise
- NO test plan in body unless explicitly requested
- Title uses PR diff as source of truth, not commit history alone
