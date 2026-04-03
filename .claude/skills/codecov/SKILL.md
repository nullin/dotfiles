---
name: codecov
allowed-tools: Bash(curl *), Read
description: Query Codecov.io API for code coverage data - totals, trends, comparisons, flags, PRs, and repo stats. Use when the user mentions Codecov, coverage percentages, coverage regressions, wants to compare coverage between branches or commits, asks about coverage flags or components, wants aggregate coverage stats across repos, or mentions a codecov.io URL. Also trigger when investigating PR coverage impact or checking if coverage thresholds are met.
---

# Codecov API

## Authentication

Token stored in `~/.netrc`:

```
machine app.codecov.io
  password <token>
```

Auth pattern for all curl commands:

```bash
CODECOV_TOKEN=$(awk '/machine app.codecov.io/{found=1} found && /password/{print $2; exit}' ~/.netrc)
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "https://api.codecov.io/api/v2/github/coreweave/repos/"
```

## Defaults

- **Service:** `github`
- **Organization:** `coreweave`

When the user does not specify a repository, detect it from the current git remote:

```bash
# Extract repo name from git remote
REPO=$(git remote get-url origin 2>/dev/null | sed -E 's|.*/([^/]+?)(\.git)?$|\1|')
```

When the user specifies a different org or repo, use those instead.

## Base URL

All endpoints use: `https://api.codecov.io/api/v2/{service}/{owner}/`

## Quick Reference

| Task | Endpoint |
|------|----------|
| List repos | `GET /repos/?page_size=100&active=true` |
| Search repos | `GET /repos/?search={term}` |
| Repo detail | `GET /repos/{repo}/` |
| Coverage totals | `GET /repos/{repo}/totals/` |
| Coverage totals for branch | `GET /repos/{repo}/totals/?branch={branch}` |
| Coverage totals for commit | `GET /repos/{repo}/totals/?sha={sha}` |
| Coverage trend | `GET /repos/{repo}/coverage/` |
| File coverage report | `GET /repos/{repo}/report/` |
| Report tree (directory breakdown) | `GET /repos/{repo}/report-tree/` |
| Compare commits | `GET /repos/{repo}/compare/?base={sha}&head={sha}` |
| Compare via PR | `GET /repos/{repo}/compare/?pullid={id}` |
| List branches | `GET /repos/{repo}/branches/` |
| Branch detail | `GET /repos/{repo}/branches/{branch}/` |
| List flags | `GET /repos/{repo}/flags/` |
| List components | `GET /repos/{repo}/components/` |
| List PRs | `GET /repos/{repo}/pulls/?state=open` |
| PR detail | `GET /repos/{repo}/pulls/{pullid}/` |
| Commit list | `GET /repos/{repo}/commits/` |
| Commit detail | `GET /repos/{repo}/commits/{sha}/` |

All endpoint paths are relative to the base URL.

## Query Parameters

Common parameters across paginated endpoints:

- `page` - page number (default: 1)
- `page_size` - results per page (default: 20, max varies)

Coverage-specific filters (on totals, report, report-tree):

- `branch` - filter by branch name
- `sha` - filter by commit SHA
- `path` - filter by file path prefix
- `flag` - filter by flag name
- `component_id` - filter by component

## Workflows

### Get Aggregate Coverage Stats Across Repos

Useful for org-wide coverage reporting. Paginate through all active repos and collect their totals:

```bash
CODECOV_TOKEN=$(awk '/machine app.codecov.io/{found=1} found && /password/{print $2; exit}' ~/.netrc)
BASE="https://api.codecov.io/api/v2/github/coreweave"

# Get all active repos (paginate as needed)
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/?active=true&page_size=100&page=1"
```

Then for each repo, fetch totals:

```bash
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/{repo_name}/totals/"
```

Present as a summary table sorted by coverage percentage.

### Check Coverage for Current Repo

```bash
CODECOV_TOKEN=$(awk '/machine app.codecov.io/{found=1} found && /password/{print $2; exit}' ~/.netrc)
REPO=$(git remote get-url origin 2>/dev/null | sed -E 's|.*/([^/]+?)(\.git)?$|\1|')
BASE="https://api.codecov.io/api/v2/github/coreweave"

# Default branch totals
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/totals/"
```

### Compare Coverage Between Branches

```bash
# Compare feature branch against main
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/compare/?base={main_sha}&head={feature_sha}"
```

Or compare via pull request:

```bash
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/compare/?pullid={pr_number}"
```

### Check PR Coverage Impact

```bash
# Get PR coverage comparison
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/pulls/{pullid}/"

# Get detailed file-level comparison
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/compare/?pullid={pullid}"
```

### Coverage by Flag

Flags let teams track coverage for different test suites (unit, integration, etc.) independently:

```bash
# List all flags for a repo
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/flags/"

# Get totals filtered to a specific flag
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/totals/?flag={flag_name}"
```

### Coverage Trend Over Time

```bash
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/coverage/"
```

### Directory-Level Coverage Breakdown

```bash
# Get coverage tree (shows coverage per directory/file)
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/report-tree/"

# Filter to a specific path prefix
curl -s -H "Authorization: Bearer $CODECOV_TOKEN" \
  "$BASE/repos/$REPO/report-tree/?path=src/internal/"
```

## Output Formatting

When presenting coverage data, format as human-readable summaries rather than raw JSON.

**Coverage totals example:**

```
cw-eng-cli (main): 72.4% coverage
  Lines: 3,412 / 4,713 covered
  Branches: 891 / 1,203 covered
  Methods: 412 / 498 covered
```

**Repo comparison table example:**

```
Repository              Branch   Coverage   Change
cw-eng-cli              main     72.4%      +1.2%
kubernetes-operator     main     68.1%      -0.3%
api-gateway             main     81.7%       0.0%
```

**PR impact example:**

```
PR #1234: Add user validation
  Base (main):  72.4%
  Head:         73.1%
  Diff:        +0.7%
  New lines:    48/52 covered (92.3%)
```

## Pagination

The API returns paginated results. The response includes:

```json
{
  "count": 150,
  "next": "https://api.codecov.io/api/v2/.../repos/?page=2",
  "previous": null,
  "results": [...]
}
```

When collecting aggregate data, follow `next` until null. Keep page_size at 100 to minimize requests.

## Error Handling

- **401**: Token invalid or expired - check ~/.netrc
- **404**: Repo not found or not activated in Codecov
- **429**: Rate limited - back off and retry
