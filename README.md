# dotfiles

Dotfiles managed with [yadm](https://yadm.io/).

## Fresh Mac Setup

1. Install Xcode Command Line Tools:

```bash
xcode-select --install
```

2. Install [Homebrew](https://brew.sh/).

3. Install yadm and clone:

```bash
brew install yadm
yadm clone git@github.com:nullin/dotfiles.git --bootstrap
```

The bootstrap script will install all Homebrew packages, apply macOS defaults, and configure Touch ID for sudo.
