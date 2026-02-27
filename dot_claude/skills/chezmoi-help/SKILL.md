---
name: chezmoi-help
description: Chezmoi dotfile management reference for this specific setup - templates, workflows, and safety rules
---

# Chezmoi Dotfile Management

## Setup

- **Source**: `~/.local/share/chezmoi/` (git repo: `nullin/dotfiles`, public)
- **Config**: `~/.config/chezmoi/chezmoi.toml`
- **Destination**: `$HOME`
- **Git**: `autoCommit = true`, `autoPush = true` - every `chezmoi add`/`forget`/`re-add` auto-commits and pushes
- **Bootstrap**: `run_once_install-packages.sh.tmpl` installs Homebrew, Nix, runs darwin-rebuild

## Template Data

Defined in `~/.config/chezmoi/chezmoi.toml` under `[data]`:

| Variable | Example Value | Used In |
|----------|--------------|---------|
| `name` | `"Nalin Makar"` | gitconfig |
| `email` | `"nullin@users.noreply.github.com"` | gitconfig |
| `github_username` | `"nullin"` | gh hosts.yml |
| `goprivate` | `"github.com/coreweave/*"` | zshrc, cursor settings |
| `username` | `"nmakar"` | configuration.nix |
| `hostname` | `"CW-JTXR767KJ5-L"` | (available, not yet used) |
| `corporate_path` | `"/opt/coreweave/bin"` | configuration.nix |

On a second Mac, edit `chezmoi.toml` to set correct `hostname` and `username`.

## Templated Files (5 files)

These files use Go template variables and require special handling:

| Source File | Template Variables |
|------------|-------------------|
| `dot_gitconfig.tmpl` | `{{ .name }}`, `{{ .email }}` |
| `dot_zshrc.tmpl` | `{{ .goprivate }}` |
| `dot_config/nix/configuration.nix.tmpl` | `{{ .corporate_path }}`, `{{ .username }}` |
| `dot_config/cursor/settings.json.tmpl` | `{{ .goprivate }}` |
| `dot_config/gh/private_hosts.yml.tmpl` | `{{ .github_username }}` |

### CRITICAL: Updating Templated Files

**NEVER run `chezmoi add` or `chezmoi re-add` on a templated file.** It overwrites the `.tmpl` source with literal values, destroying template variables.

Wrong:
```bash
# Destroys {{ .goprivate }} in dot_zshrc.tmpl
chezmoi add ~/.zshrc        # BAD
chezmoi re-add ~/.zshrc     # BAD
```

Correct:
```bash
# Edit the template source directly
chezmoi edit ~/.zshrc        # Opens dot_zshrc.tmpl in $EDITOR
# -or-
vi ~/.local/share/chezmoi/dot_zshrc.tmpl

# Preview what would change on disk
chezmoi diff ~/.zshrc

# Apply to disk (requires user confirmation per rules)
chezmoi apply ~/.zshrc
```

### Verifying Templates Render Correctly

```bash
# Zero output = template produces identical output to current disk file
chezmoi diff ~/.gitconfig

# Show what the template would produce
chezmoi cat ~/.gitconfig

# Test a template expression
chezmoi execute-template '{{ .goprivate }}'
```

## Plain Files (everything else)

All other tracked files are plain copies - no templates. Standard workflow:

```bash
# Disk changed, update source (auto-commits and pushes)
chezmoi add ~/.tmux.conf
chezmoi re-add ~/.config/starship.toml

# Source changed (pulled from another machine), update disk
chezmoi diff
chezmoi apply
```

## .chezmoiignore Whitelist

The `.claude/` directory uses a whitelist pattern - only explicitly listed paths are tracked:

```
.claude/*
!.claude/CLAUDE.md
!.claude/settings.json
!.claude/agents
!.claude/hooks
!.claude/prompts
!.claude/rules
!.claude/skills
```

**Important**: Uses single-star `.claude/*`, not double-star `.claude/**`. Double-star prevents negation (`!`) from re-including child entries. This is the same limitation as `.gitignore`.

What this means:
- New generated dirs (cache, plugins, agent-memory, teams, tasks) are ignored by default
- Only portable config is tracked: agents, hooks, prompts, rules, skills, CLAUDE.md, settings.json

## Quick Reference

| Task | Command |
|------|---------|
| Check sync status | `chezmoi status` |
| Preview changes | `chezmoi diff` |
| Apply source to disk | `chezmoi apply` (needs confirmation) |
| Add plain file | `chezmoi add <file>` |
| Edit templated file | `chezmoi edit <file>` |
| Remove from tracking | `chezmoi forget --force <file>` |
| Pull and apply from remote | `chezmoi update` |
| Show template data | `chezmoi data` |
| Test template | `chezmoi execute-template '{{ .variable }}'` |
| Show managed files | `chezmoi managed` |
| Check what's ignored | `chezmoi ignored` |
| Diagnose issues | `chezmoi doctor` |

## Status Codes

`chezmoi status` outputs two columns followed by the file path:

| Status | Meaning | Action |
|--------|---------|--------|
| `MM` | Modified on disk since last sync | `chezmoi re-add` (plain files only) |
| `DA` | In repo but deleted from disk | `chezmoi forget --force` or `chezmoi apply` to restore |
| ` A` | In repo, not on disk | `chezmoi apply` |
| ` M` | Repo is newer than disk | `chezmoi apply` |
| `A ` | On disk, not in repo | `chezmoi add` |
| ` R` | Script to run | `chezmoi apply` to execute |

## File Naming Conventions

| Prefix/Suffix | Meaning | Example |
|--------------|---------|---------|
| `dot_` | Leading dot | `dot_zshrc` -> `.zshrc` |
| `private_` | Mode 0600 | `private_hosts.yml` |
| `executable_` | Mode 0755 | `executable_git-safety.sh` |
| `readonly_` | Read-only | `readonly_dot_aerospace.toml` |
| `empty_` | Empty file | `empty_dot_hushlogin` |
| `.tmpl` suffix | Go template | `dot_zshrc.tmpl` |
| `run_once_` | Run-once script | `run_once_install-packages.sh.tmpl` |

## Autonomy Guidelines

**Execute without asking:**
- `chezmoi status`, `diff`, `verify`, `doctor`, `data`
- `chezmoi managed`, `ignored`
- `chezmoi source-path`, `cat`
- `chezmoi execute-template`
- `chezmoi git -- status`, `chezmoi git -- log`

**Require user confirmation:**
- `chezmoi apply` (always show `chezmoi diff` first)
- `chezmoi add`, `chezmoi re-add` (modifies source, auto-commits/pushes)
- `chezmoi forget` (removes from tracking, auto-commits/pushes)
- `chezmoi update` (pulls remote changes and applies)
- Any direct git operations in the source repo
