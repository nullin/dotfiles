# dotfiles

Dotfiles managed by [chezmoi](https://www.chezmoi.io/). Supports multiple machines via a `machine_type` variable (work/personal) that conditionally includes machine-specific configuration.

## Quick start

On a fresh Mac:

```bash
curl -fsLS https://raw.githubusercontent.com/nullin/dotfiles/main/bootstrap.sh | bash
```

This will:

1. Install chezmoi
2. Prompt for machine type (work/personal), name, email, and GitHub username
3. Deploy all dotfiles and run the package installer (Homebrew + Nix)
4. Generate an SSH key and prompt you to add it to GitHub
5. Switch the dotfiles remote from HTTPS to SSH

If nix was just installed and `darwin-rebuild` is not yet in your PATH, open a new terminal and run:

```bash
sudo darwin-rebuild switch --flake ~/.config/nix
```

## Updating

Pull the latest dotfiles and apply:

```bash
chezmoi update
```

## Multi-machine support

During `chezmoi init`, you choose a machine type. This controls which configuration is deployed:

| Feature | work | personal |
|---------|------|----------|
| GOPRIVATE | Prompted | Empty |
| Corporate PATH | Prompted | Omitted |
| Claude Code integrations | All (Glean, internal MCP, etc.) | Public plugins only |
| Nix packages | Full set | Full set |
| Shell aliases and tools | All | All |

To change machine type after setup, edit `~/.config/chezmoi/chezmoi.toml` and run `chezmoi apply`.

## Structure

- `.chezmoi.toml.tmpl` - init template that prompts for machine-specific values
- `run_once_install-packages.sh.tmpl` - installs Homebrew and Nix on first run
- `dot_config/nix/` - nix-darwin configuration (packages, system defaults, fonts)
- `dot_claude/` - Claude Code settings, agents, rules, and skills
- `dot_zshrc.tmpl` - zsh configuration with zinit plugins
- `dot_gitconfig.tmpl` - git identity and preferences

Template files (`*.tmpl`) use Go template syntax and reference variables from `chezmoi.toml`.

## Adding new configuration

```bash
chezmoi add ~/.config/some/file    # Track a new file
chezmoi edit ~/.config/some/file   # Edit the source (use for .tmpl files)
chezmoi diff                       # Preview changes before applying
chezmoi apply                      # Apply changes to home directory
```

If new content is work-specific, make the source file a template and gate it with:

```
{{- if eq .machine_type "work" }}
...work-only content...
{{- end }}
```
