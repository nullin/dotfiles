#!/bin/bash
set -e

# Bootstrap a fresh Mac with chezmoi-managed dotfiles.
# Usage: curl -fsLS https://raw.githubusercontent.com/nullin/dotfiles/main/bootstrap.sh | bash

REPO="nullin/dotfiles"
HTTPS_URL="https://github.com/${REPO}.git"
SSH_URL="git@github.com:${REPO}.git"

echo "==> Installing chezmoi"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"

echo "==> Running chezmoi init (will prompt for machine type and identity)"
chezmoi init --apply --guess-repo-url=false "$HTTPS_URL"

echo "==> Generating SSH key"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -C "$(chezmoi execute-template '{{ .email }}')" -f "$HOME/.ssh/id_ed25519" -N ""
    echo ""
    echo "==> Add this public key to https://github.com/settings/keys"
    echo ""
    cat "$HOME/.ssh/id_ed25519.pub"
    echo ""
    read -r -p "Press Enter after adding the key to GitHub..."
    ssh -T git@github.com 2>&1 || true
fi

echo "==> Switching dotfiles remote to SSH"
cd "$(chezmoi source-path)"
git remote set-url origin "$SSH_URL"

echo "==> Done"
echo ""
echo "If darwin-rebuild did not run (nix not yet in PATH), open a new terminal and run:"
echo "  sudo darwin-rebuild switch --flake ~/.config/nix"
