# Batch Spec YAML - Full Reference

## Top-Level Fields

| Field | Required | Description |
|-------|----------|-------------|
| `version` | No (default: 1) | Schema version - use `2` for all new specs |
| `name` | Yes | Unique identifier within namespace. Case-preserving, URL-safe. |
| `description` | No | Markdown description shown in the UI |
| `on` | Yes | List of repository targeting rules |
| `steps` | No | List of steps to execute per matched repo |
| `changesetTemplate` | No (required if steps set) | How to create changesets |
| `importChangesets` | No | Import existing PRs/MRs under this batch change |
| `transformChanges` | No | Split diffs into multiple changesets |
| `workspaces` | No | Monorepo workspace configuration |

---

## `on` - Repository Selection

```yaml
on:
  # Search query (Sourcegraph search syntax)
  - repositoriesMatchingQuery: "lang:go file:go.mod"

  # Specific repository, default branch
  - repository: github.com/myorg/myrepo

  # Specific repository + branch
  - repository: github.com/myorg/myrepo
    branch: feature/my-branch

  # Specific repository + multiple branches (one changeset per branch)
  - repository: github.com/myorg/myrepo
    branches:
      - main
      - release/v2
      - release/v3
```

---

## `steps` - Execution Steps

Each step runs a shell command inside a Docker container within a checkout of the matched repository.

```yaml
steps:
  - run: <shell command>
    container: <docker image>
    env:                      # optional
      VAR_NAME: value
    if: <expression>          # optional - skip step if false
    files:                    # optional - create files in container
      /path/in/container: |
        file contents
    mount:                    # optional - mount host files
      - path: /host/path
        mountpoint: /container/path
    outputs:                  # optional - capture values for later steps
      myVar:
        value: ${{ step.stdout }}
        format: text          # text (default) or json
```

### Step field details

**`run`** - Shell command, executed as `sh -c '<run>'`. Use `|` for multi-line. Exit code 0 = success.

**`container`** - Docker image to run in. Image is pulled if not cached. Use explicit tags to ensure reproducibility (not `:latest`).

**`env`** - Environment variables. Two formats:
```yaml
env:
  KEY: value          # object format

env:
  - KEY: value        # array format (allows dynamic values)
  - KEY: ${{ outputs.step1.myVar }}
```

**`if`** - Conditional step execution using template expressions:
```yaml
if: ${{ matches_path_filter "*.go" }}    # only if Go files changed
if: ${{ eq repository.name "myrepo" }}  # only in specific repo
```

**`outputs`** - Capture values from stdout/stderr for use in later steps:
```yaml
outputs:
  currentVersion:
    value: ${{ step.stdout }}
    format: text

# Use in next step:
run: echo "Upgrading from ${{ outputs.currentVersion }}"
```

---

## `changesetTemplate` - Changeset Definition

```yaml
changesetTemplate:
  title: "chore: update dependency foo"
  body: |
    ## Summary
    Updates foo from 1.x to 2.x across all services.

    See migration guide: https://...
  branch: batch/update-foo
  commit:
    message: "chore: update foo to 2.0"
    author:
      name: Automation Bot
      email: bot@example.com
  published: false    # false | true | "draft" | array of patterns
  fork: false         # create on fork instead of origin repo (v5.1+)
```

### `published` field

Controls whether a changeset is created on the code host as a PR/MR.

| Value | Effect |
|-------|--------|
| `false` | Changeset exists only in Sourcegraph (default) |
| `true` | Creates a PR/MR immediately |
| `"draft"` | Creates as a draft PR/MR (where supported) |

Array form for per-repo control:
```yaml
published:
  - github.com/myorg/prod-*: draft      # draft for prod repos
  - github.com/myorg/test-*: true       # publish for test repos
  - "*": false                           # everything else: unpublished
```

**Note:** Once published, a changeset cannot be unpublished or changed to draft.

---

## `importChangesets` - Import Existing PRs

Bring existing PRs/MRs under batch change management without re-creating them:

```yaml
importChangesets:
  - repository: github.com/myorg/myrepo
    externalIDs:
      - 42
      - 105
```

---

## `transformChanges` - Split into Multiple Changesets

Group file changes by directory into separate PRs:

```yaml
transformChanges:
  group:
    - directory: frontend/
      branch: batch/update-frontend      # overrides changesetTemplate.branch
      repository: github.com/myorg/monorepo  # optional: limit to specific repo

    - directory: backend/
      branch: batch/update-backend
```

Files not matched by any `group` entry go into a changeset using the default branch from `changesetTemplate`.

---

## `workspaces` - Monorepo Support

Execute steps once per workspace root instead of once per repository:

```yaml
workspaces:
  - rootAtLocationOf: package.json       # file marking workspace root
    in: github.com/myorg/monorepo        # repo glob pattern
    onlyFetchWorkspace: true             # only checkout this workspace's files
```

With `workspaces`, each matched workspace gets its own changeset. The `branch` in `changesetTemplate` gets `-workspace-<path>` appended.

---

## Template Variables

Available in `run`, `env`, `if`, `outputs`, and `changesetTemplate` fields:

| Variable | Type | Description |
|----------|------|-------------|
| `repository.name` | string | Full repo name, e.g. `github.com/org/repo` |
| `repository.branch` | string | Current branch being processed |
| `batch_change.name` | string | Name from the spec |
| `step.stdout` | string | Stdout of the current step |
| `step.stderr` | string | Stderr of the current step |
| `outputs.<stepName>.<varName>` | string | Output captured by a previous step |
| `previous_step.stdout` | string | Stdout of the immediately preceding step |

Helper functions in `if` expressions:
- `matches_path_filter "glob"` - true if any changed file matches the glob
- `eq x y` - equality check
- `ne x y` - inequality check
- `and x y`, `or x y`, `not x` - boolean logic

---

## Full Example: Dependency Upgrade

```yaml
version: 2
name: upgrade-react-18
description: |
  Upgrades React from 17 to 18 across all frontend services.

  See: https://react.dev/blog/2022/03/29/react-v18

on:
  - repositoriesMatchingQuery: >
      file:package.json "react": repo:github.com/myorg/

steps:
  - run: |
      sed -i 's/"react": "^17\.[0-9]*\.[0-9]*"/"react": "^18.0.0"/g' package.json
      sed -i 's/"react-dom": "^17\.[0-9]*\.[0-9]*"/"react-dom": "^18.0.0"/g' package.json
    container: alpine:3
    if: ${{ matches_path_filter "package.json" }}

changesetTemplate:
  title: "chore: upgrade React from 17 to 18"
  body: |
    ## Summary
    Automated upgrade of React from 17.x to 18.x.

    **Migration checklist:**
    - [ ] Review React 18 breaking changes
    - [ ] Test rendering in development
    - [ ] Update ReactDOM.render to createRoot if needed

    See [migration guide](https://react.dev/blog/2022/03/29/react-v18).
  branch: batch/upgrade-react-18
  commit:
    message: "chore(deps): upgrade react and react-dom to 18"
  published: draft    # start as draft, manually publish after review
```
