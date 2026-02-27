# CW CLI - CoreWeave Engineering CLI

CoreWeave command-line tool for engineering workflows. Built by CI Build Services team.

## Quick Reference

| Task | Command |
|------|---------|
| Create new repo | `cw repo create` |
| Add component to repo | `cw scaffold generate -c` |
| Generate archetype locally | `cw scaffold generate -a` |
| Setup dev environment | `cw dev init` |
| Start local CKS cluster | `cw dev cks --start` |
| Stop local CKS cluster | `cw dev cks --stop` |
| Update CLI | `cw update` |
| Check version | `cw version` |

## Skills for Detailed Help

- `/cw-repo` - Interactive repository creation with templates
- `/cw-scaffold` - Interactive component scaffolding
- `/cw-dev` - Interactive dev environment setup
- `/cw-explore` - Explore CoreWeave repositories and CLI capabilities
- `/cw-argocd` - ArgoCD operations
- `/cw-confluence` - Confluence API operations

## Authentication

Tokens stored at `~/.cw/cli/gh.json`, auto-refresh every 8 hours.

**Re-authenticate:**
```bash
rm -rf ~/.cw/cli/gh.json && cw update
```

**Required scopes:** read:user, read:org, repo, user:email, workflow

## Configuration

- **Config directory:** `~/.cw/cli/`
- **Logs:** `~/.cw/cli/cli.log`
- **Cache:** `~/.cw/cli/cached-templates/`

**Clear cache:** `rm -rf ~/.cw/cli/cached-templates/`

## Getting Help

- **Slack:** #ci-build-services
- **CBS Helpdesk:** JIRA Service Desk portal
- **Source:** github.com/coreweave/cw-eng-cli

## Autonomy Guidelines

**Execute autonomously:**
- `cw version` - Check version
- `cw update --check` - Check for updates

**Require user confirmation:**
- `cw repo create` - Creates GitHub repository
- `cw scaffold generate` - Generates files
- `cw dev init` - Installs software
- `cw dev cks` - Starts/stops clusters
- `cw update` - Updates CLI binary
