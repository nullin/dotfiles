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
   - Stop if on main or master
   - Run `git status` to check for uncommitted changes (stop if the working tree is dirty)

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

These guard against lost or silently rewritten work:

- Don't squash on main or master.
- Don't proceed with a dirty working tree - stash or stop first.
- Show the commits and wait for confirmation before squashing.
- Verify the result afterward (`git diff <base> --stat` should show no lost changes).
- Don't push after squashing unless the user asks - squashing rewrites history.
