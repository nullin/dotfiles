---
name: aviator
allowed-tools: Bash(av *), Bash(git *)
description: Stacked PR workflows using Aviator CLI (av). Use when working with stacked PRs, creating PR stacks, syncing branches in a stack, or managing multi-part features with dependent branches. Triggers on "stacked PR", "av stack", "aviator", "stack sync", "create a stack", or when working on features that should be split into incremental PRs.
---

# Aviator CLI (av)

Aviator CLI is used for stacked PR workflow and flexible git operations.

See also: [PR Workflow](../rules/pr-workflow.md) for general PR best practices.

## Important: Deprecated Commands

Many `av stack *` subcommands are deprecated. Use the top-level equivalents:

| Deprecated | Use instead |
|---|---|
| `av stack tree` | `av tree` |
| `av stack branch` | `av branch` |
| `av stack sync` | `av sync` |
| `av stack restack` | `av restack` |
| `av stack adopt` | `av adopt` |
| `av stack next` | `av next` |
| `av stack prev` | `av prev` |

## Critical: Always Use av to Create Branches

**NEVER create stack branches with raw `git checkout -b` or `git branch`.** Branches created outside `av` are not tracked in av's metadata, which means:

- `av restack` and `av sync` will not know about them
- `av tree` will not show them
- You lose all stack-aware operations and fall back to manual `git rebase --onto` chains

**If a branch already exists outside av**, adopt it:

```bash
# Adopt current branch with a specific parent
av adopt --parent main

# Adopt a remote branch and its PR stack
av adopt --remote branch-name
```

## Flexible Git Operations

With Aviator CLI you CAN:

- Use `git commit --amend` to fix recent commits
- Use `git rebase -i` for interactive rebasing
- Use `git rebase` to update branches
- Use `av sync` to sync stacked PRs
- Use history rewriting tools when appropriate
- Use `git push --force-with-lease` when needed (with user approval)

The flexible git workflow supports:

- Atomic, well-crafted commits through rewriting
- Stacked PRs for incremental reviews
- Clean git history before merging

## Common Commands

```bash
# Create a new branch in the stack
av branch <branch-name>

# Sync the current stack with main
av sync

# Submit a PR for the current branch
av pr create

# Restack branches after changes (e.g., after amending a commit)
av restack

# Adopt an existing branch into a stack
av adopt --parent <parent-branch>

# Navigate between branches in the stack
av next
av prev

# Show the current stack structure
av tree
```

## Stacked PRs Workflow

1. **Start from main**: `git checkout main && git pull`
2. **Create first branch**: `av branch feature-part-1`
3. **Make changes and commit**: Work on first part, commit changes
4. **Create PR**: `av pr create`
5. **Create next branch**: `av branch feature-part-2`
6. **Make more changes**: Work on dependent part, commit changes
7. **Create second PR**: `av pr create`
8. **Sync after feedback**: `av sync` to propagate changes up the stack

## Restacking After Amending a Commit

When you amend a commit in the middle of a stack, all downstream branches need rebasing. If you used `av branch` to create them, this is simple:

```bash
# After amending a commit on any branch in the stack:
git commit --amend --no-edit
av restack          # Rebases all downstream branches automatically
```

If branches were NOT created with `av` (manual git branches), you must restack manually:

```bash
# Manual restack: rebase each downstream branch one at a time
# You need the OLD commit hash that was the base of each branch
git rebase --onto <new-parent-tip> <old-parent-tip> <downstream-branch>
```

This is error-prone because:
- You must track old commit SHAs before amending
- Conflicts in shared files (e.g., test files edited in multiple PRs) require manual resolution at each layer
- Each resolved conflict changes the SHA, so you need the new tip for the next rebase

**Lesson: always use `av branch` so `av restack` can handle this automatically.**

## Inserting a New PR at the Base of a Stack

When you need to add a new PR before the existing stack (e.g., bug fixes that should land first):

```bash
# 1. Create the new branch from main
git checkout main
av branch new-base-branch

# 2. Make changes, commit
git add ... && git commit -m "fix: ..."

# 3. Reparent the old first branch onto the new one
git checkout old-first-branch
av reparent --parent new-base-branch

# 4. Restack everything
av restack
```

## Conflict Resolution During Restack

When files are modified in multiple PRs (common with test files), conflicts will occur during restack. Tips:

- After resolving a conflict, `git add <file>` then `git rebase --continue`
- If a file was created in an earlier PR and extended in a later PR, the later PR's rebase may show modify/delete conflicts - resolve by keeping both sets of changes
- Use `git rerere` to record resolutions so repeated restacks reuse them automatically

## Best Practices

- **Always create branches with `av branch`** - never raw git
- Keep commits atomic and logical within each branch
- Use descriptive branch names that indicate dependencies
- Sync frequently to avoid conflicts: `av sync`
- Review the entire stack before submitting PRs: `av tree`
- Use `av restack` after rebasing or amending individual branches
- Verify `av tree` shows all branches before restacking

## Integration with Claude Code

When Claude creates commits in a stacked PR workflow:

- Use `av branch` (not `git checkout -b`) for new stack branches
- Use atomic commits per logical change
- Use `av restack` after amending commits
- Use `av sync` to push and sync with remote
- Suggest stack creation for multi-part features
- Respect user approval before force-pushing
- After force-push, verify PRs still target correct base branches

## Relationship to Git

Aviator wraps and enhances git:

- All standard git commands still work
- `av` commands provide stack-aware operations
- Local git operations (commit, amend, rebase) don't require approval
- Remote operations (push, force push) still require user approval per Claude Code rules

$ARGUMENTS
