# PR Workflow

For stacked PR workflows, see [Aviator CLI](aviator.md).

## Writing PR Titles and Descriptions

Always use the PR diff as the source of truth for what changes are in the PR - not the commit history.

**Why?** Commits in a PR branch may include changes that:

- Were later superseded by parallel changes merged into the base branch
- Appear in commit history but cancel out in the final diff
- Are merge commits that don't represent actual PR changes

**Example:** A commit might change `int32` to `*int32`, but if the base branch independently made the same change, the PR diff will show no type change.

## Method

```bash
# 1. Get the actual diff (source of truth)
gh pr diff <pr-number> --repo <owner>/<repo>

# 2. Get commit history (use only to explain WHY changes were made)
gh pr view <pr-number> --repo <owner>/<repo> --json commits \
  --jq '.commits[] | "\(.oid[:7]) \(.messageHeadline)"'

# 3. Compare branches to see unique commits
gh api repos/<owner>/<repo>/compare/<base>...<head> \
  --jq '.commits[] | "\(.sha[:7]) \(.commit.message | split("\n")[0])"'
```

## Rules

1. First examine `gh pr diff` to identify actual changes relative to merge target
2. Reference commit history only to explain *why* changes were made
3. Never claim a change is in the PR based solely on commit history - verify it appears in the diff
4. For PRs targeting non-main branches, link to the base branch PR in the description
