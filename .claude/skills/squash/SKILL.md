---
name: squash
description: Squash commits on current branch with safety verification. Use when user says "/squash", "squash commits", or wants to combine multiple commits into one.
allowed-tools:
  - Bash(git:*)
  - Read
---

# Squash Commits

Safely squash commits on the current branch into a single commit.

## Process

1. **Verify branch state**
   - Run `git branch --show-current` to confirm current branch
   - ABORT if on main or master
   - Run `git status` to check for uncommitted changes (abort if working tree is dirty)

2. **Determine base branch**
   - Default base: `main`
   - If user specifies a different base (stacked PRs), use that
   - Verify the base branch exists

3. **Show what will be squashed**
   - Run `git log --oneline <base>..HEAD` to show commits
   - Show the count: "N commits will be squashed into one"
   - Wait for user to confirm or provide a commit message

4. **Squash**
   - `git reset --soft $(git merge-base <base> HEAD)`
   - `git add -A`
   - Commit with the user-provided message
   - If no message provided, combine existing commit subjects into bullet points

5. **Verify**
   - Run `git log --oneline -3` to show the result
   - Run `git diff <base> --stat` to confirm no changes were lost

## Safety Rules

- NEVER squash on main or master
- NEVER proceed with uncommitted changes (stash or abort)
- ALWAYS show commits before squashing and wait for confirmation
- ALWAYS verify the result after squashing
- NEVER push after squashing unless user explicitly asks
