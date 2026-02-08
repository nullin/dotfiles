# Aviator CLI (av)

Aviator CLI is used for stacked PR workflow and flexible git operations.

See also: [PR Workflow](pr-workflow.md) for general PR best practices.

## Flexible Git Operations

Unlike strict git workflows, with Aviator CLI you CAN:

- Use `git commit --amend` to fix recent commits
- Use `git rebase -i` for interactive rebasing
- Use `git rebase` to update branches
- Use `av stack sync` to sync stacked PRs
- Use history rewriting tools when appropriate
- Use `git push --force-with-lease` when needed (with user approval)

The flexible git workflow supports:

- Atomic, well-crafted commits through rewriting
- Stacked PRs for incremental reviews
- Clean git history before merging

## Common Commands

```bash
# Create a new branch in the stack
av stack branch <branch-name>

# Sync the current stack with main
av stack sync

# Submit a PR for the current branch
av pr create

# Restack branches after changes
av stack restack

# Adopt an existing branch into a stack
av stack adopt <branch-name>

# Navigate between branches in the stack
av stack next
av stack prev

# Show the current stack structure
av stack tree
```

## Stacked PRs Workflow

1. **Start from main**: `git checkout main && git pull`
2. **Create first branch**: `av stack branch feature-part-1`
3. **Make changes and commit**: Work on first part, commit changes
4. **Create PR**: `av pr create`
5. **Create next branch**: `av stack branch feature-part-2`
6. **Make more changes**: Work on dependent part, commit changes
7. **Create second PR**: `av pr create`
8. **Sync after feedback**: `av stack sync` to propagate changes up the stack

## Best Practices

- Keep commits atomic and logical within each branch
- Use descriptive branch names that indicate dependencies
- Sync frequently to avoid conflicts: `av stack sync`
- Review the entire stack before submitting PRs: `av stack tree`
- Use `av stack restack` after rebasing individual branches
- When amending commits, sync the stack: `git commit --amend && av stack sync`

## Integration with Claude Code

When Claude creates commits in a stacked PR workflow:

- Use atomic commits per logical change
- Support interactive rebasing when requested
- Use `av stack sync` after rebasing or amending
- Suggest stack creation for multi-part features
- Respect user approval before force-pushing

## Relationship to Git

Aviator wraps and enhances git:

- All standard git commands still work
- `av` commands provide stack-aware operations
- Local git operations (commit, amend, rebase) don't require approval
- Remote operations (push, force push) still require user approval per Claude Code rules
