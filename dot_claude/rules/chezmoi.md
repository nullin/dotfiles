---
description: Use Chezmoi to sync local configuration to a remote dotfiles repository
---

## Rules

- NEVER run `chezmoi apply` without explicit user confirmation
- NEVER update the dotfiles repo (commit/push) using chezmoi without explicit confirmation
- Always show `chezmoi diff` output before applying changes
- Status codes: D=deleted from target, A=added to target, M=modified

## Sensitive Data Scan

The dotfiles repo (`nullin/dotfiles`) is **public**. Before any `chezmoi add`, `chezmoi re-add`, or direct source file edit that will be committed:

1. **Scan every file being added or updated** for sensitive data:
   - API keys, tokens, secrets, passwords
   - Auth0 identifiers, OAuth client IDs/secrets
   - Corporate email addresses, user/team IDs
   - Private keys, certificates
   - Session cookies, JWTs
   - Any value that looks like a credential (long base64 strings, `sk-*`, `ghp_*`, `Bearer *`, etc.)
2. **If sensitive data is found**: STOP. Do not add/commit the file. Report the finding and discuss whether to:
   - Remove the sensitive values from the file before adding
   - Add the file to `.chezmoiignore` instead
   - Templatize the sensitive values (move to `chezmoi.toml` data, which is local-only)
3. **If clean**: proceed with the add/commit

This applies to both new files and updates to existing tracked files.
