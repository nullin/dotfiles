---
name: chezmoi-help
description: Comprehensive Chezmoi dotfile management reference with commands, templates, and workflows
---

# Chezmoi - Dotfile Management

Chezmoi manages your dotfiles across multiple machines, with support for templates, encryption, and machine-specific configurations.

## Overview

- **Source Directory**: `~/.local/share/chezmoi/` - Your dotfiles repository
- **Destination**: `$HOME` - Where files are applied
- **Git Integration**: Source directory is a git repository
- **Templates**: Go templates for machine-specific configuration
- **Encryption**: Support for age, gpg, and other encryption tools
- **Scripts**: Run commands during apply (one-time, on-change)

## Quick Reference

| Task | Command |
|------|---------|
| Initialize chezmoi | `chezmoi init` |
| Add file to chezmoi | `chezmoi add <file>` |
| Edit file | `chezmoi edit <file>` |
| Apply changes | `chezmoi apply` |
| See what would change | `chezmoi diff` |
| Update from repo | `chezmoi update` |
| Add file as template | `chezmoi add --template <file>` |
| Add encrypted file | `chezmoi add --encrypt <file>` |
| Check for issues | `chezmoi doctor` |
| Check sync status | `chezmoi status` |
| Re-add modified file | `chezmoi re-add` |
| Remove file | `chezmoi forget <file>` |
| Change to source dir | `chezmoi cd` |
| Execute in source dir | `chezmoi execute-template` |

## Status Codes

`chezmoi status` outputs two characters per line followed by the file path. Each character represents a change type:

| Code | Meaning |
|------|---------|
| ` ` (space) | No change |
| `A` | Added |
| `D` | Deleted |
| `M` | Modified |
| `R` | Run (scripts) |

The two columns represent:
- **First column**: what chezmoi would change in the **source state** (repo) to match destination (disk)
- **Second column**: what chezmoi would change in the **destination** (disk) to match source (repo)

### Common Status Patterns

| Status | Meaning | Action |
|--------|---------|--------|
| `MM` | File modified on disk since last sync | `chezmoi re-add <file>` to push local changes to repo |
| `DA` | File exists in repo but deleted from disk | `chezmoi forget --force <file>` to remove from repo, or `chezmoi apply` to restore on disk |
| ` A` | File in repo, not yet on disk | `chezmoi apply` to create on disk |
| ` M` | File in repo is newer than disk | `chezmoi apply` to update disk |
| `A ` | File on disk, not in repo | `chezmoi add <file>` to track it |

**Common pitfall**: `DA` does NOT mean the file needs to be added. It means chezmoi tracks a file that no longer exists on disk. Either restore it with `apply` or stop tracking it with `forget --force`.

## Getting Started

### Initialize Chezmoi

```bash
# Initialize with new repo
chezmoi init

# Initialize with existing repo
chezmoi init https://github.com/username/dotfiles.git

# Initialize and apply immediately
chezmoi init --apply https://github.com/username/dotfiles.git

# Initialize with SSH
chezmoi init git@github.com:username/dotfiles.git
```

### Basic Workflow

```bash
# Add a file to chezmoi
chezmoi add ~/.bashrc

# Edit the file (opens in $EDITOR)
chezmoi edit ~/.bashrc

# See what would change
chezmoi diff

# Apply changes
chezmoi apply

# Or combine: edit and apply
chezmoi edit --apply ~/.bashrc
```

## File Management

### Adding Files

```bash
# Add single file
chezmoi add ~/.gitconfig

# Add entire directory
chezmoi add ~/.config/nvim

# Add as template (for machine-specific values)
chezmoi add --template ~/.ssh/config

# Add encrypted file
chezmoi add --encrypt ~/.ssh/id_rsa

# Add with custom attributes
chezmoi add --template --encrypt ~/.aws/credentials

# Re-add file after manual modification
chezmoi re-add ~/.gitconfig
```

### Editing Files

```bash
# Edit in source directory
chezmoi edit ~/.bashrc

# Edit and apply immediately
chezmoi edit --apply ~/.bashrc

# Edit multiple files
chezmoi edit ~/.bashrc ~/.zshrc

# Diff before applying
chezmoi diff
chezmoi apply
```

### Removing Files

```bash
# Remove from chezmoi (keeps destination file)
chezmoi forget ~/.old-config

# Remove from both chezmoi and destination
chezmoi forget ~/.old-config
rm ~/.old-config
```

## Templates

### Basic Templates

Chezmoi uses Go templates for machine-specific configuration.

```bash
# Add file as template
chezmoi add --template ~/.gitconfig
```

Example `~/.local/share/chezmoi/dot_gitconfig.tmpl`:
```ini
[user]
    name = {{ .name }}
    email = {{ .email }}
[core]
    editor = {{ .editor }}
{{- if eq .chezmoi.os "darwin" }}
[credential]
    helper = osxkeychain
{{- end }}
```

### Template Data

Define template data in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    name = "Your Name"
    email = "you@example.com"
    editor = "vim"

[data.personal]
    github_user = "username"
```

Or in YAML (`~/.config/chezmoi/chezmoi.yaml`):
```yaml
data:
  name: "Your Name"
  email: "you@example.com"
  editor: "vim"
  personal:
    github_user: "username"
```

### Template Variables

Chezmoi provides built-in variables:

```
{{ .chezmoi.os }}           # Operating system (linux, darwin, windows)
{{ .chezmoi.osRelease }}    # OS release info
{{ .chezmoi.arch }}         # Architecture (amd64, arm64)
{{ .chezmoi.hostname }}     # Hostname
{{ .chezmoi.username }}     # Username
{{ .chezmoi.homeDir }}      # Home directory
{{ .chezmoi.sourceDir }}    # Chezmoi source directory
```

### Template Functions

```gotemplate
{{- if eq .chezmoi.os "darwin" }}
# macOS specific
{{- else if eq .chezmoi.os "linux" }}
# Linux specific
{{- end }}

{{- if .is_work }}
# Work machine configuration
{{- end }}

{{ .email | quote }}         # Quote string
{{ .name | upper }}          # Uppercase
{{ .path | base }}           # Basename
{{ .path | dir }}            # Directory
{{ includeTemplate "common.conf" . }}  # Include another template
```

### Template Examples

**SSH Config with machine-specific hosts:**
```
# ~/.local/share/chezmoi/private_dot_ssh/config.tmpl
Host *
    IdentityAgent ~/.1password/agent.sock

{{- if .is_work }}
Host work-*
    User {{ .work_username }}
    IdentityFile ~/.ssh/work_key
{{- end }}

{{- if .is_personal }}
Host github.com
    User {{ .github_username }}
    IdentityFile ~/.ssh/personal_key
{{- end }}
```

**Zshrc with OS-specific configuration:**
```bash
# ~/.local/share/chezmoi/dot_zshrc.tmpl
export EDITOR="{{ .editor }}"
export NAME="{{ .name }}"

{{- if eq .chezmoi.os "darwin" }}
# macOS specific
export PATH="/opt/homebrew/bin:$PATH"
{{- else if eq .chezmoi.os "linux" }}
# Linux specific
export PATH="/usr/local/bin:$PATH"
{{- end }}
```

## Encryption

### Age Encryption

```bash
# Install age
# macOS: brew install age
# Linux: apt install age / nix profile install nixpkgs#age

# Generate age key
age-keygen -o ~/.config/chezmoi/key.txt

# Configure chezmoi to use age
cat >> ~/.config/chezmoi/chezmoi.toml << EOF
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1..."  # public key from key.txt
EOF

# Add encrypted file
chezmoi add --encrypt ~/.ssh/id_rsa
chezmoi add --encrypt ~/.aws/credentials
```

### GPG Encryption

```bash
# Configure chezmoi to use gpg
cat >> ~/.config/chezmoi/chezmoi.toml << EOF
encryption = "gpg"
[gpg]
    recipient = "your.email@example.com"
EOF

# Add encrypted file
chezmoi add --encrypt ~/.ssh/id_rsa
```

### Encrypted Files

```bash
# Add encrypted file
chezmoi add --encrypt ~/.netrc

# Edit encrypted file (decrypts, opens editor, re-encrypts)
chezmoi edit ~/.netrc

# View encrypted file
chezmoi cat ~/.netrc

# In source directory, encrypted files have .age or .asc extension
# ~/.local/share/chezmoi/private_dot_netrc.age
```

## Scripts

Scripts run during `chezmoi apply` to automate setup tasks.

### Script Types

- `run_once_` - Run once ever
- `run_onchange_` - Run when script content changes
- `run_before_` - Run before applying files
- `run_after_` - Run after applying files

### Script Examples

**Install packages once:**

```bash
# ~/.local/share/chezmoi/run_once_install-packages.sh
#!/bin/bash
set -e

{{- if eq .chezmoi.os "darwin" }}
brew install ripgrep fd bat
{{- else if eq .chezmoi.os "linux" }}
sudo apt update
sudo apt install -y ripgrep fd-find bat
{{- end }}
```

**Update on change:**

```bash
# ~/.local/share/chezmoi/run_onchange_install-tools.sh.tmpl
#!/bin/bash
# Tools to install (changing this list triggers reinstall):
# - ripgrep
# - fd
# - bat
set -e

echo "Installing tools..."
```

**Run before applying:**

```bash
# ~/.local/share/chezmoi/run_before_backup.sh
#!/bin/bash
# Backup important files before chezmoi applies changes
tar czf ~/backup-$(date +%Y%m%d).tar.gz ~/.bashrc ~/.zshrc
```

**Run after applying:**
```bash
# ~/.local/share/chezmoi/run_after_setup-vim.sh
#!/bin/bash
# Install vim plugins after applying vimrc
vim +PlugInstall +qall
```

### Script Order

1. `run_before_` scripts
2. Files are applied
3. `run_after_` scripts

Within each group, scripts run in alphabetical order.

### Conditional Scripts

```bash
# ~/.local/share/chezmoi/run_once_install-macos.sh.tmpl
{{- if eq .chezmoi.os "darwin" }}
#!/bin/bash
# macOS-specific setup
brew install --cask iterm2
{{- end }}
```

## Managing Multiple Machines

### Machine-Specific Configuration

Define machine types in `~/.config/chezmoi/chezmoi.toml`:

```toml
[data]
    is_work = false
    is_personal = true
    is_server = false
```

Or prompt during init:

```toml
# ~/.local/share/chezmoi/.chezmoi.toml.tmpl
{{- $is_work := promptBoolOnce . "is_work" "Is this a work machine" -}}
{{- $is_personal := promptBoolOnce . "is_personal" "Is this a personal machine" -}}

[data]
    is_work = {{ $is_work }}
    is_personal = {{ $is_personal }}
```

Use in templates:
```
{{- if .is_work }}
# Work-specific configuration
{{- else }}
# Personal configuration
{{- end }}
```

### Machine-Specific Files

Use `.chezmoi.os.arch` suffix for OS/architecture-specific files:

```
dot_bashrc.darwin          # macOS only
dot_bashrc.linux           # Linux only
dot_config/sway/config.linux.amd64  # Linux x86_64 only
```

### Hostname-Specific Files

```
dot_bashrc.{{ .chezmoi.hostname }}.tmpl
```

## Git Integration

Chezmoi source directory is a git repository.

```bash
# Change to source directory
chezmoi cd

# Or execute git commands directly
chezmoi git status
chezmoi git add .
chezmoi git commit -m "Update dotfiles"
chezmoi git push

# Exit source directory
exit

# Update from remote and apply
chezmoi update

# Pull without applying
chezmoi git pull

# Push changes
chezmoi cd
git add .
git commit -m "Update configuration"
git push
exit
```

### Common Git Workflow

```bash
# Make changes
chezmoi edit ~/.bashrc

# Review changes
chezmoi diff

# Apply changes
chezmoi apply

# Commit to git
chezmoi cd
git add .
git commit -m "Update bashrc"
git push
exit
```

## Configuration File

`~/.config/chezmoi/chezmoi.toml` or `chezmoi.yaml`:

```toml
# Source directory (default: ~/.local/share/chezmoi)
sourceDir = "~/dotfiles"

# Editor for chezmoi edit
[edit]
    command = "nvim"

# Diff tool
[diff]
    command = "git"
    args = ["diff", "--color=always"]

# Merge tool
[merge]
    command = "vimdiff"

# Git auto-commit
[git]
    autoCommit = false
    autoPush = false

# Template data
[data]
    name = "Your Name"
    email = "you@example.com"
    editor = "vim"

# Age encryption
encryption = "age"
[age]
    identity = "~/.config/chezmoi/key.txt"
    recipient = "age1..."
```

## File Naming

Chezmoi uses prefixes to determine file attributes:

| Prefix | Attribute | Example |
|--------|-----------|---------|
| `dot_` | Dotfile | `dot_bashrc` → `~/.bashrc` |
| `private_` | Mode 0600 | `private_dot_ssh/config` → `~/.ssh/config` |
| `executable_` | Mode 0755 | `executable_script.sh` → `~/script.sh` |
| `symlink_` | Symlink | `symlink_link` → symlink |
| `readonly_` | Read-only | `readonly_file` → read-only file |
| `.tmpl` | Template | `dot_bashrc.tmpl` → template processed |

Combine prefixes:
```
private_executable_dot_local/bin/script.tmpl
→ ~/.local/bin/script (mode 0700, templated)
```

## Common Workflows

### Initial Setup on New Machine

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply username/dotfiles
```

### Daily Usage

```bash
# Edit configuration
chezmoi edit ~/.bashrc

# Review changes
chezmoi diff

# Apply changes
chezmoi apply

# Commit and push
chezmoi cd
git add .
git commit -m "Update bashrc"
git push
exit
```

### Update Existing File

```bash
# Modified ~/.bashrc directly
vim ~/.bashrc

# Re-add to chezmoi
chezmoi re-add ~/.bashrc

# Commit changes
chezmoi cd
git add dot_bashrc
git commit -m "Update bashrc"
git push
exit
```

### Sync Local State to Dotfiles Repo

When files have been modified or deleted on disk outside of chezmoi (common with
tools that manage their own config), sync those changes back to the repo:

```bash
# 1. Check what's out of sync
chezmoi status

# 2. Interpret the output:
#    MM .zshrc              - modified on disk, re-add to sync
#    DA .claude/rules/x.md  - in repo but deleted from disk, forget to clean up

# 3. Re-add modified files (MM) to push local changes to repo
chezmoi re-add ~/.zshrc ~/.config/cursor/settings.json

# 4. Remove stale files (DA) that no longer exist on disk
#    Use --force to skip interactive confirmation (required in non-TTY environments)
chezmoi forget --force ~/.claude/rules/old-file.md

# 5. Verify clean state
chezmoi status
```

**Note on autoCommit/autoPush**: If `git.autoCommit` and `git.autoPush` are enabled
in chezmoi config, `re-add` and `forget` will automatically commit and push. Otherwise,
manually commit via `chezmoi cd` and git commands.

### Sync Across Machines

```bash
# On machine A: edit and push
chezmoi edit ~/.bashrc
chezmoi apply
chezmoi cd
git add . && git commit -m "Update" && git push
exit

# On machine B: pull and apply
chezmoi update
```

## Verification and Debugging

```bash
# Check for issues
chezmoi doctor

# Verify what would change
chezmoi verify

# Show diff
chezmoi diff

# Dry run (show what would happen)
chezmoi apply --dry-run --verbose

# Show source state
chezmoi source-path ~/.bashrc

# Show target state
chezmoi target-path ~/.bashrc

# Execute template
chezmoi execute-template "{{ .chezmoi.os }}"

# Show data
chezmoi data
```

## Advanced Features

### External Files

Include external files in templates:

```gotemplate
{{- include "common-config.sh" -}}
```

### Template Functions

```gotemplate
# Include file
{{ include "file.txt" }}

# Include template
{{ includeTemplate "template.tmpl" . }}

# Lookup in password manager
{{ (onepasswordRead "op://vault/item/field") }}

# Lookup in keyring
{{ keyring "service" "user" }}

# Execute command
{{ output "command" "arg1" "arg2" }}
```

### Password Manager Integration

**1Password:**
```gotemplate
# ~/.local/share/chezmoi/dot_gitconfig.tmpl
[user]
    email = {{ onepasswordRead "op://Private/Email/username" }}
[github]
    token = {{ onepasswordRead "op://Private/GitHub/token" }}
```

**Bitwarden:**
```gotemplate
{{ (bitwardenFields "item-name").password.value }}
```

**Pass:**
```gotemplate
{{ (passFields "entry-name").password }}
```

### Prompt for Data

```toml
# ~/.local/share/chezmoi/.chezmoi.toml.tmpl
{{- $email := promptStringOnce . "email" "Email address" -}}
{{- $name := promptStringOnce . "name" "Full name" -}}
{{- $is_work := promptBoolOnce . "is_work" "Is this a work machine" -}}

[data]
    email = {{ $email | quote }}
    name = {{ $name | quote }}
    is_work = {{ $is_work }}
```

## Integration with Nix

Chezmoi and Nix complement each other:

**Manage Nix config with Chezmoi:**
```bash
# Add Nix flake to chezmoi
chezmoi add ~/.config/nix/flake.nix
chezmoi add ~/.config/home-manager/home.nix

# Add as templates for machine-specific config
chezmoi add --template ~/.config/nix-darwin/flake.nix
```

**Script to rebuild after apply:**
```bash
# ~/.local/share/chezmoi/run_after_rebuild-nix.sh.tmpl
#!/bin/bash
set -e

{{- if eq .chezmoi.os "darwin" }}
darwin-rebuild switch --flake ~/.config/nix-darwin
{{- else if eq .chezmoi.os "linux" }}
{{-   if stat "/etc/nixos" }}
sudo nixos-rebuild switch --flake /etc/nixos
{{-   else }}
home-manager switch --flake ~/.config/home-manager
{{-   end }}
{{- end }}
```

## Troubleshooting

### Check Configuration

```bash
# Diagnose issues
chezmoi doctor

# Show configuration
chezmoi data

# Verify files
chezmoi verify

# Show diff
chezmoi diff
```

### Fix Common Issues

**File not being templated:**
```bash
# Re-add with template flag
chezmoi forget ~/.bashrc
chezmoi add --template ~/.bashrc
```

**Encryption not working:**
```bash
# Check age configuration
cat ~/.config/chezmoi/chezmoi.toml

# Test age key
age -d ~/.local/share/chezmoi/private_file.age

# Re-add encrypted file
chezmoi forget ~/.netrc
chezmoi add --encrypt ~/.netrc
```

**Changes not applying:**
```bash
# Force apply
chezmoi apply --force

# Or remove and re-add
chezmoi forget ~/.bashrc
chezmoi add ~/.bashrc
chezmoi apply
```

## Autonomy Guidelines for Claude

**Execute autonomously:**
- `chezmoi status` - Show sync status between source and destination
- `chezmoi diff` - Show what would change
- `chezmoi verify` - Verify files
- `chezmoi doctor` - Diagnose issues
- `chezmoi data` - Show template data
- `chezmoi source-path` - Show source path
- `chezmoi target-path` - Show target path
- `chezmoi execute-template` - Test templates
- `chezmoi cd` followed by `git status`, `git log`, etc.

**Require user confirmation:**
- `chezmoi add` - Add files to chezmoi
- `chezmoi edit` - Edit files
- `chezmoi apply` - Apply changes
- `chezmoi update` - Update from remote
- `chezmoi init` - Initialize chezmoi
- `chezmoi forget` - Remove files
- Any git operations that modify history
- Any changes to configuration files

## Resources

- [Chezmoi Documentation](https://www.chezmoi.io/)
- [Chezmoi GitHub](https://github.com/twpayne/chezmoi)
- [Quick Start](https://www.chezmoi.io/quick-start/)
- [User Guide](https://www.chezmoi.io/user-guide/)
- [Reference](https://www.chezmoi.io/reference/)
