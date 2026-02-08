# Global Reference

## Quality Gates

Before committing:

- Code compiles/lints without errors
- All tests pass
- No hardcoded secrets
- Changes are minimal and focused

## Code Style

- Read before modifying
- Match existing patterns
- Minimal changes only
- Delete unused code completely
- No over-engineering
- No emojis. No em dashes - use hyphens or colons instead.

## Communication

- Be explicit and direct
- Provide context (why, not just what)
- Use positive framing
- Be concise

## GitHub Interactions

**NEVER perform write operations to GitHub without explicit user approval.**

This includes:

- Creating issues (`gh issue create`)
- Creating PRs (`gh pr create`)
- Posting comments or replies
- Deleting issues, PRs, branches
- Any other GitHub API write operations

Before any GitHub write operation:

1. Show the user exactly what will be created/posted
2. Wait for explicit approval (e.g., "yes", "go ahead", "create it")
3. Only then execute the API call

## Git Remote Operations

**NEVER push to remote repositories without explicit user approval.**

This includes pushing commits, tags, or any branch updates to remote.

Before running `git push`:

1. Show what will be pushed (commits, branch)
2. Wait for explicit approval
3. Only then execute the push

**ESPECIALLY CRITICAL**: Never run `git push --force` or `git push --force-with-lease` without approval, as these can destroy work on shared branches.

Local operations (commit, branch, stash, rebase) are fine without approval.

### Comment Formatting

- Always prefix comments with `[via Claude]` to indicate they were written by Claude
- When replying to an existing comment, post as a reply (not a new comment in the main thread)

### Replying to PR Review Comments

To reply to a PR review comment, use the `/replies` endpoint with the comment ID:

```bash
# CORRECT - posts as a reply to an existing comment
gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments/COMMENT_ID/replies \
  -X POST -f body="[via Claude] Your reply here"

# WRONG - posts as a new comment in the main thread
gh api repos/OWNER/REPO/issues/PR_NUMBER/comments \
  -X POST -f body="[via Claude] Your reply here"
```

To find comment IDs, fetch PR comments first:

```bash
gh api repos/OWNER/REPO/pulls/PR_NUMBER/comments --jq '.[] | {id, user: .user.login, body: .body[:80]}'
```

## Rules & Skills Index

| Activity | Always-loaded rules | On-demand skills |
|----------|-------------------|------------------|
| Writing code | `comments`, `error-handling`, `security`, `simple`, `grug-brain` | `/go-review-standards` |
| Code review | `code-review-guide`, `grug-brain`, `comments` | `/diff-review`, `/branch-review`, `/grug-review`, `/review-pr` |
| PRs and commits | `pr-workflow` | `/git-commit`, `/finishing-a-development-branch` |
| Documentation | `comments` | `/documentation-standards`, `/diataxis-documentation` |
| Planning | `simple`, `task-tracking` | `/interview`, `/brainstorming`, `/writing-plans` |
| Jira/Confluence | - | `/jira-setup`, `/cw-confluence` |
| CoreWeave infra | `agent-teams` | `/cw-teleport`, `/cw-argocd`, `/cw-dev`, `/kubernetes` |

## Principles

- Assumptions are the enemy. Never guess numerical values - benchmark instead of estimating. When uncertain, measure.
  Say "this needs to be measured" rather than inventing statistics.
- **Interaction**: Clarify unclear requests, then proceed autonomously. Only ask for help when scripts timeout (>2min) or genuine blockers arise.
- **Ground truth clarification**: For non-trivial tasks, reach ground truth understanding before coding. Simple tasks execute immediately.
  Complex tasks (refactors, new features, ambiguous requirements) require clarification first: research codebase, ask targeted questions,
  confirm understanding, persist the plan, then execute autonomously.
- **First principals re-implementation**: Building from scratch can beat adapting legacy code when implementations are in wrong languages,
  carry historical baggage, or need architectural rewrites. Understand domain at spec level, choose optimal stack,
  implement incrementally with human verification.
- **Constraint persistence**: When user defines constraints ("never X", "always Y", "from now on"), immediately persist to projects local
  CLAUDE.md. Acknowledge, write, confirm.
