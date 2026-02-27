---
description: Use Chezmoi to sync local configuration to a remote dotfiles repository
---

## Rules

- NEVER run `chezmoi apply` without explicit user confirmation
- NEVER update the dotfiles repo (commit/push) using chezmoi without explicit confirmation
- Always show `chezmoi diff` output before applying changes
- Status codes: D=deleted from target, A=added to target, M=modified
