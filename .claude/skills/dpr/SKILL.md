---
name: dpr
description: Commit, push, and create a draft PR in one shot. Use for "/dpr", "draft pr", or "commit and pr".
allowed-tools:
  - Bash(git:*)
  - Bash(gh:*)
  - Read
---

# Draft PR (commit, push, create)

One-shot workflow: commit changes, push branch, create draft PR.

Invoking this skill is explicit approval to commit, push, and create a draft PR. No additional confirmation gates - just show what you're doing at each step.

## Process

### 1. Preflight checks

- `git branch --show-current` - stop if on main or master
- `git status` - identify staged and unstaged changes

If nothing is staged and nothing is uncommitted, stop with a message.

### 2. Determine what to commit

- If there are staged changes, commit exactly what is staged (do not add unstaged files)
- If nothing is staged but there are uncommitted changes, stage all tracked modified files (`git add -u`) then commit
- Don't stage untracked files automatically - warn the user if untracked files exist and let them decide

### 3. Commit

- `git log --oneline -10` to detect commit message style (conventional commits, etc.)
- `git diff --cached --stat` and `git diff --cached` to understand the changes
- Write a commit message that matches the project's style:
  - Subject line under 50 chars, imperative mood, no period
  - Body explains why if the change is non-trivial
  - Use HEREDOC format for the commit
- Commit the changes

### 4. Push

- Check for remote tracking: `git rev-parse --abbrev-ref @{upstream} 2>/dev/null`
- Push with `-u origin <branch>` if no upstream, otherwise `git push`

### 5. Draft PR

- Check if a PR already exists: `gh pr view --json url 2>/dev/null`
- If a PR exists, report its URL and skip creation
- If no PR exists:
  - Determine base branch (default: `main`)
  - Title: derive from the diff against base, keep under 70 chars
  - Body: `## Summary` with 1-3 bullet points based on `gh pr diff`
  - No "Test plan" section - never include one
  - Create with `gh pr create --draft --base <target>`
- Report the PR URL

### 6. Summary

Print a concise summary:
- What was committed (files, message)
- Where it was pushed
- PR URL (new or existing)

## Safety rules

- Stop if on main or master.
- Don't stage untracked files without user input.
- Don't force push.
- Create the PR as a draft.
- Don't include a "Test plan" section in the PR description.
- If any step fails, stop and report the error rather than continuing.
