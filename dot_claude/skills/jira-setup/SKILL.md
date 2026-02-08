---
name: jira-setup
description: Install and configure Jira CLI for issue tracking
---

# Jira CLI Setup

## Installation

```bash
# macOS
brew install ankitpokhrel/jira-cli/jira-cli

# Go install
go install github.com/ankitpokhrel/jira-cli/cmd/jira@latest
```

## API Token

**NEVER** store API tokens in config files committed to git.

1. Generate token at: https://id.atlassian.com/manage-profile/security/api-tokens

2. Add to `~/.netrc`:
   ```
   machine company.atlassian.net
     login your-email@company.com
     password your-api-token-here
   ```

3. Secure the file:
   ```bash
   chmod 600 ~/.netrc
   ```

See: https://github.com/ankitpokhrel/jira-cli/discussions/356

## Configuration

```bash
jira init
```

Prompts:

- Installation type: `Cloud`
- Link to Jira server: `https://company.atlassian.net`
- Login email: `your-email@company.com`
- Default project: (e.g., `NETDP`)
- Default board: (e.g., `NETDP Sprint Board`)

Config saved to: `~/.config/.jira/.config.yml`

## Verification

```bash
# Check authentication
jira me

# List projects you have access to
jira project list
```

## Troubleshooting

```bash
# Debug authentication issues
jira me --debug

# Reset configuration
rm -rf ~/.config/.jira
jira init
```
