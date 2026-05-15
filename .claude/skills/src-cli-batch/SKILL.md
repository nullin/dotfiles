---
name: src-cli-batch
description: Sourcegraph src CLI batch changes expert. Use this skill whenever the user wants to create, run, preview, apply, publish, update, or troubleshoot batch changes using the src CLI. Triggers on "batch change", "batch spec", "src batch", "batch apply", "batch preview", "changeset", "automate code changes across repos", "src-cli", or any request to make the same code change across multiple repositories at scale. Also triggers when writing or debugging batch spec YAML files.
---

# src-cli Batch Changes

Batch Changes lets you make the same code change across many repositories by writing a batch spec - a YAML file describing what to change and where. The src CLI executes those changes locally and uploads them to Sourcegraph for review.

## Core Workflow

```
1. src batch new        → scaffold a spec file
2. (edit spec)          → write your steps
3. src batch validate   → check spec syntax
4. src batch preview    → execute locally, upload for review in the UI
5. src batch apply      → execute and create/update the batch change
6. (UI or re-apply)     → publish changesets to code hosts
```

## Setup

Install src CLI - download the binary that matches your Sourcegraph instance version:
```bash
# macOS
curl -L https://<SOURCEGRAPH_URL>/.api/src-cli/src_darwin_arm64 -o /usr/local/bin/src && chmod +x /usr/local/bin/src

# Linux
curl -L https://<SOURCEGRAPH_URL>/.api/src-cli/src_linux_amd64 -o /usr/local/bin/src && chmod +x /usr/local/bin/src
```

If the Sourcegraph endpoint isn't known, check `~/.zshrc` for `SRC_ENDPOINT` before asking the user:
```bash
grep SRC_ENDPOINT ~/.zshrc
```

Authenticate:
```bash
src login $SRC_ENDPOINT
```

Or set environment variables:
```bash
export SRC_ENDPOINT=<url>
export SRC_ACCESS_TOKEN=<your-token>
```

## Deleting Batch Changes

`src batch` has no delete subcommand. Use the GraphQL `deleteBatchChange` mutation:

```bash
src api -query '
mutation {
  deleteBatchChange(batchChange: "<batch-change-id>") {
    alwaysNil
  }
}
'
```

Get the batch change ID from the list query (e.g. `QmF0Y2hDaGFuZ2U6NQ==`).

**Before deleting:** Check changeset stats. Deleting a batch change does NOT close open PRs on GitHub - those remain open. If you want to clean them up first, use the UI's bulk "Close changesets" action before deleting.

DRAFT batch changes with 0 changesets are safe to delete immediately.

## Listing Batch Changes

`src batch` has no list subcommand. Use `src api` with GraphQL:

```bash
src api -query '
query {
  batchChanges(first: 50) {
    totalCount
    nodes {
      name
      state
      namespace { namespaceName }
      changesetsStats { total open merged closed draft }
      createdAt
      updatedAt
    }
  }
}
'
```

Filter by namespace (user or org):
```bash
src api -query 'query { batchChanges(first: 50, namespace: "my-org") { nodes { name state } } }'
```

## Commands

### `src batch new` - Scaffold a spec file

```bash
src batch new -f my-change.batch.yaml
```

Creates a starter batch spec with all required fields. Edit the generated file before running.

### `src batch validate` - Check spec syntax

```bash
src batch validate -f my-change.batch.yaml
```

Validates the spec against the Sourcegraph API without executing anything. Run this first to catch errors in your YAML before executing steps.

### `src batch preview` - Execute and upload for UI review

```bash
src batch preview -f my-change.batch.yaml
src batch preview -f my-change.batch.yaml -n my-org   # under org namespace
```

Executes each step locally in Docker containers, then uploads the results to Sourcegraph. Outputs a URL to review changes in the web UI before they go live. You can click "Apply" in the UI, or use `src batch apply` instead.

### `src batch apply` - Execute and create/update the batch change

```bash
src batch apply -f my-change.batch.yaml
src batch apply -f my-change.batch.yaml -n my-org
```

Like `preview`, but immediately creates or updates the batch change. Use this for CI/CD pipelines or when you've already reviewed via `preview`.

## Batch Spec Structure

```yaml
version: 2
name: my-batch-change           # URL-safe identifier, unique per namespace
description: |
  Describe what this change does and why. Rendered as Markdown.

# Target repositories
on:
  - repositoriesMatchingQuery: "file:package.json repo:github.com/myorg/"
  - repository: github.com/myorg/specific-repo
    branch: main

# Steps run in Docker containers, one per matched repo
steps:
  - run: sed -i 's/old-dep@1.0/new-dep@2.0/g' package.json
    container: alpine:3

  - run: |
      npm install
      npm run lint --fix
    container: node:18
    env:
      - NODE_ENV: ci

# How the changeset (PR/MR) looks on the code host
changesetTemplate:
  title: "chore: upgrade old-dep to 2.0"
  body: |
    Automated upgrade of old-dep from 1.0 to 2.0.

    See the migration guide: https://example.com/migration
  branch: batch/upgrade-old-dep
  commit:
    message: "chore: upgrade old-dep from 1.0 to 2.0"
  published: false     # false = unpublished, true = published, "draft" = draft PR
```

### `on` - Targeting repositories

```yaml
on:
  # Search query - most flexible
  - repositoriesMatchingQuery: "file:Makefile lang:go repo:myorg"

  # Specific repo + branch
  - repository: github.com/myorg/infra
    branch: main

  # Specific repo + multiple branches
  - repository: github.com/myorg/api
    branches:
      - main
      - release/v2
```

### `steps` - Running changes

```yaml
steps:
  # Simple shell command
  - run: sed -i 's/foo/bar/g' config.yaml
    container: alpine:3

  # Multi-line with environment variables
  - run: |
      python3 update_config.py
      git diff --stat
    container: python:3.11
    env:
      - DRY_RUN: "false"
      - TARGET_VERSION: "2.0.0"

  # Conditional - only run if a file exists
  - run: go mod tidy
    container: golang:1.21
    if: ${{ matches_path_filter "go.mod" }}

  # Mount local files into the container
  - run: python3 /scripts/migrate.py
    container: python:3.11
    mount:
      - path: /home/user/scripts/migrate.py
        mountpoint: /scripts/migrate.py
```

### `changesetTemplate.published` - Controlling when PRs are created

```yaml
# Don't create PRs yet - just stage in Sourcegraph
published: false

# Create PRs immediately
published: true

# Create as draft PRs
published: draft

# Per-repo control using glob patterns
published:
  - github.com/myorg/safe-repo: true
  - github.com/myorg/risky-*: draft
  - "*": false
```

### `transformChanges` - Split one spec into multiple PRs

```yaml
transformChanges:
  group:
    - directory: frontend/
      branch: batch/upgrade-frontend
    - directory: backend/
      branch: batch/upgrade-backend
```

### `workspaces` - Monorepo support

```yaml
workspaces:
  - rootAtLocationOf: package.json
    in: github.com/myorg/monorepo
    onlyFetchWorkspace: true
```

### `importChangesets` - Bring existing PRs under management

```yaml
importChangesets:
  - repository: github.com/myorg/repo
    externalIDs:
      - 123
      - 456
```

## Common Flags

| Flag | Applies to | Purpose |
|------|-----------|---------|
| `-f FILE` | all | Batch spec file to read |
| `-n / -namespace` | preview, apply | User or org namespace |
| `-j N` | preview, apply | Parallel jobs (default: CPU cores) |
| `-timeout DURATION` | preview, apply | Max time per step (default: 1h) |
| `-clear-cache` | preview, apply | Re-execute all steps (ignore cache) |
| `-fail-fast` | preview, apply | Stop on first error |
| `-skip-errors` | preview, apply | Log errors and continue |
| `-keep-logs` | preview, apply | Retain step execution logs |
| `-workspace MODE` | preview, apply | `auto`, `bind`, or `volume` |
| `-allow-unsupported` | validate, preview, apply | Allow unsupported code hosts |
| `-v` | preview, apply | Verbose output |

## Caching

Steps are cached by default at `~/.cache/sourcegraph/batch`. Re-use this to avoid re-running expensive steps on unchanged repos:

```bash
# Normal run - uses cache
src batch apply -f spec.yaml

# Force re-run all steps
src batch apply -f spec.yaml -clear-cache

# Custom cache location
src batch apply -f spec.yaml -cache /tmp/my-cache
```

## Publishing Changesets

Changesets start as `published: false` - they exist only in Sourcegraph. To create actual PRs on the code host:

**Option 1 - Set in spec and re-apply:**
```yaml
changesetTemplate:
  published: true
```
Then run `src batch apply -f spec.yaml` again.

**Option 2 - Publish via Sourcegraph UI:**
Open the batch change in the web UI, select changesets, and click "Publish changesets".

Once published, a changeset cannot be unpublished or changed back to draft.

## Common Patterns

### Dry run before committing

Use `src batch preview` to review diffs in the UI before creating the batch change:
```bash
src batch preview -f spec.yaml
# Opens URL in terminal - review, then click Apply or discard
```

### Run in CI

For automated batch change updates:
```bash
export SRC_ENDPOINT=https://sourcegraph.example.com
export SRC_ACCESS_TOKEN=$(cat /run/secrets/sg-token)
src batch apply -f spec.yaml -namespace ci-automation -j 4
```

### Limit to specific repos while testing

Temporarily narrow your `on` query during development:
```yaml
on:
  # Normally: - repositoriesMatchingQuery: "file:package.json"
  - repository: github.com/myorg/test-repo-only
```

### Re-apply after repo changes

If repos change (new matches, different branches), run `apply` again - it will update existing changesets and create new ones for newly matched repos.

## Troubleshooting

**"No repositories found"**
- Check your `repositoriesMatchingQuery` in the Sourcegraph search UI first
- Ensure the matched repos are accessible to your token

**Step exits with non-zero code**
- Without `-fail-fast`, other repos continue; errors are logged
- Add `-v` to see full step output
- The batch spec `run` field runs in `sh -c`; use `set -e` if you want pipelines to fail

**Cache producing stale results**
- Run with `-clear-cache` to force re-execution
- Or delete `~/.cache/sourcegraph/batch`

**"unauthorized" errors**
- Re-run `src login` to refresh credentials
- Confirm your token has `repo` scope on the code host

**Docker issues**
- Docker must be running - batch steps execute in containers
- Use `-workspace bind` if volume mounts are causing issues
- Use `-run-as-root` if a container requires root (use cautiously)

**Wrong namespace**
- Default namespace is the authenticated user
- Use `-n org-name` to create under an organization

## Reference

For full batch spec YAML reference including all fields and options, see `references/batch-spec-reference.md`.
