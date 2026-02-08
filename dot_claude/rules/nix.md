# Nix - Declarative Package Management and System Configuration

Nix is a powerful package manager that can be used for reproducible system configuration and development environments.

## Overview

- **Nix Package Manager**: Cross-platform package manager (Linux, macOS)
- **NixOS**: Linux distribution built on Nix
- **nix-darwin**: Nix-based system configuration for macOS
- **Home Manager**: User environment and dotfile management
- **Flakes**: Modern, reproducible Nix configuration format

## Quick Reference

| Task | Command |
|------|---------|
| Search packages | `nix search nixpkgs <package>` |
| Install package (flakes) | `nix profile install nixpkgs#<package>` |
| List installed packages | `nix profile list` |
| Remove package | `nix profile remove <index>` |
| Update packages | `nix profile upgrade '.*'` |
| Run package temporarily | `nix shell nixpkgs#<package>` |
| Enter dev shell | `nix develop` |
| Build flake | `nix build` |
| Garbage collect | `nix-collect-garbage -d` |
| Switch system config | `sudo nixos-rebuild switch` (NixOS) |
| Switch system config | `darwin-rebuild switch` (macOS) |

## Nix Flakes

Modern Nix uses flakes for reproducible, composable configurations.

### Flake Structure

```nix
# flake.nix
{
  description = "My system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, darwin, ... }@inputs: {
    # NixOS configuration
    nixosConfigurations = {
      hostname = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./configuration.nix ];
      };
    };

    # macOS configuration
    darwinConfigurations = {
      hostname = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        modules = [ ./darwin-configuration.nix ];
      };
    };

    # Home Manager configuration
    homeConfigurations = {
      "user@hostname" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./home.nix ];
      };
    };
  };
}
```

### Flake Commands

```bash
# Initialize new flake
nix flake init

# Update flake inputs
nix flake update

# Update specific input
nix flake lock --update-input nixpkgs

# Show flake metadata
nix flake show

# Check flake for errors
nix flake check

# Build flake output
nix build .#package-name

# Run flake output
nix run .#package-name
```

## Package Management

### Searching and Installing

```bash
# Search for packages
nix search nixpkgs ripgrep
nix search nixpkgs 'python.*packages.*requests'

# Install package (creates profile entry)
nix profile install nixpkgs#ripgrep

# Install multiple packages
nix profile install nixpkgs#ripgrep nixpkgs#fd nixpkgs#bat

# Install from flake
nix profile install github:owner/repo#package

# Run package without installing
nix shell nixpkgs#ripgrep
nix shell nixpkgs#ripgrep nixpkgs#fd

# Run package directly
nix run nixpkgs#cowsay -- "Hello, Nix!"
```

### Managing Installed Packages

```bash
# List installed packages
nix profile list

# Show package details
nix profile list | grep ripgrep

# Remove package (by index from list)
nix profile remove 3

# Upgrade all packages
nix profile upgrade '.*'

# Upgrade specific package
nix profile upgrade '.*ripgrep.*'

# Rollback profile
nix profile rollback

# Show profile history
nix profile history
```

## Development Shells

### Quick Shell

```bash
# Temporary shell with packages
nix shell nixpkgs#nodejs nixpkgs#python3

# Shell with specific package version
nix shell nixpkgs/nixos-23.11#nodejs

# Shell from multiple sources
nix shell nixpkgs#go github:owner/repo#custom-tool
```

### Development Flake

```nix
# flake.nix
{
  description = "Development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            go
            gopls
            go-tools
            golangci-lint
          ];

          shellHook = ''
            echo "Go development environment"
            go version
          '';
        };
      }
    );
}
```

```bash
# Enter development shell
nix develop

# Run command in dev shell
nix develop --command go build

# Use specific shell
nix develop .#custom-shell
```

## NixOS Configuration

### System Configuration

```nix
# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  # Boot loader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Networking
  networking.hostName = "nixos-machine";
  networking.networkmanager.enable = true;

  # Timezone and locale
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # Users
  users.users.username = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    curl
  ];

  # Enable services
  services.openssh.enable = true;
  services.docker.enable = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "23.11";
}
```

### Applying Configuration

```bash
# Test configuration (no activation)
sudo nixos-rebuild dry-build

# Build and activate
sudo nixos-rebuild switch

# Build but don't activate (use after reboot)
sudo nixos-rebuild boot

# Build and test (activates until reboot)
sudo nixos-rebuild test

# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# List generations
nix-env --list-generations --profile /nix/var/nix/profiles/system

# Delete old generations
sudo nix-collect-garbage --delete-old
```

## nix-darwin (macOS)

### Darwin Configuration

```nix
# darwin-configuration.nix
{ config, pkgs, ... }:

{
  # System packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  # Homebrew integration
  homebrew = {
    enable = true;
    brews = [ "mysql" ];
    casks = [ "visual-studio-code" ];
    taps = [ "homebrew/cask-fonts" ];
  };

  # System settings
  system.defaults = {
    dock.autohide = true;
    finder.AppleShowAllExtensions = true;
    NSGlobalDomain.AppleShowAllExtensions = true;
  };

  # Fonts
  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = 4;
}
```

### Applying Darwin Configuration

```bash
# Build and activate
darwin-rebuild switch

# Build from flake
darwin-rebuild switch --flake ~/.config/nix-darwin

# Build specific configuration
darwin-rebuild switch --flake .#hostname

# Rollback
darwin-rebuild --rollback
```

## Home Manager

### Home Configuration

```nix
# home.nix
{ config, pkgs, ... }:

{
  home.username = "username";
  home.homeDirectory = "/home/username";

  # Packages for this user
  home.packages = with pkgs; [
    ripgrep
    fd
    bat
    htop
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Your Name";
    userEmail = "your.email@example.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -la";
      gs = "git status";
    };
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "docker" ];
    };
  };

  # Dotfiles
  home.file.".vimrc".source = ./vimrc;
  home.file.".config/alacritty/alacritty.yml".source = ./alacritty.yml;

  # Environment variables
  home.sessionVariables = {
    EDITOR = "vim";
  };

  home.stateVersion = "23.11";
}
```

### Standalone Home Manager

```bash
# Install Home Manager
nix run home-manager/master -- init

# Switch configuration
home-manager switch

# Switch with flake
home-manager switch --flake ~/.config/home-manager

# Build but don't activate
home-manager build

# List generations
home-manager generations

# Remove old generations
home-manager expire-generations "-7 days"
```

### Home Manager with NixOS/nix-darwin

```nix
# In flake.nix or configuration.nix
{
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager.users.username = { pkgs, ... }: {
    home.packages = with pkgs; [ ripgrep ];
    programs.git.enable = true;
  };
}
```

## Garbage Collection

```bash
# Delete old generations and unreferenced packages
nix-collect-garbage -d

# Delete generations older than X days
nix-collect-garbage --delete-older-than 30d

# Optimize nix store
nix-store --optimize

# Check store size
du -sh /nix/store

# Show what will be deleted (dry run)
nix-collect-garbage -d --dry-run
```

## Common Patterns

### Pinning Nixpkgs Version

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";  # Specific release
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }: {
    # Use stable for most things
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem {
      modules = [
        ({ pkgs, ... }: {
          # But access unstable for specific packages
          environment.systemPackages = [
            nixpkgs-unstable.legacyPackages.x86_64-linux.package-name
          ];
        })
      ];
    };
  };
}
```

### Overlays

```nix
# overlay.nix
final: prev: {
  custom-package = prev.custom-package.overrideAttrs (old: {
    version = "custom";
    src = fetchGit { url = "..."; };
  });
}

# In configuration
{
  nixpkgs.overlays = [ (import ./overlay.nix) ];
}
```

### Managing Secrets

```nix
# Use sops-nix or agenix
{
  inputs.sops-nix.url = "github:Mic92/sops-nix";

  outputs = { sops-nix, ... }: {
    nixosConfigurations.hostname = {
      modules = [
        sops-nix.nixosModules.sops
        {
          sops.defaultSopsFile = ./secrets.yaml;
          sops.secrets.github-token = {};
        }
      ];
    };
  };
}
```

## Troubleshooting

### Check What's Using Disk Space

```bash
# Show largest store paths
nix path-info -rsSh /run/current-system | sort -hk2 | tail -20

# Show why package is in store
nix-store --query --roots /nix/store/...

# Show dependencies
nix-store --query --tree /nix/store/...
```

### Build Errors

```bash
# Show full build log
nix log /nix/store/...

# Build with verbose output
nix build --print-build-logs

# Build showing trace
nix build --show-trace
```

### Repair Store

```bash
# Check store integrity
nix-store --verify --check-contents

# Repair corrupted paths
nix-store --repair-path /nix/store/...
```

## Integration with Chezmoi

Nix and Chezmoi can work together:

```bash
# Install Nix packages
nix profile install nixpkgs#ripgrep

# Manage dotfiles with Chezmoi
chezmoi add ~/.config/nix/flake.nix
chezmoi add ~/.config/home-manager/home.nix

# Apply both
nix profile upgrade '.*' && chezmoi apply
```

See [chezmoi.md](chezmoi.md) for dotfile management.

## Autonomy Guidelines for Claude

**Execute autonomously:**
- `nix search` - Search packages
- `nix flake show` - Show flake outputs
- `nix flake check` - Check flake validity
- `nix profile list` - List installed packages
- Read Nix configuration files

**Require user confirmation:**
- `nix profile install` - Install packages
- `nix profile remove` - Remove packages
- `nixos-rebuild switch` - Apply system configuration
- `darwin-rebuild switch` - Apply macOS configuration
- `home-manager switch` - Apply user configuration
- `nix-collect-garbage` - Delete old generations
- Any modification to flake.nix or configuration files

## Resources

- [Nix Manual](https://nixos.org/manual/nix/stable/)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [Nix Pills](https://nixos.org/guides/nix-pills/)
- [NixOS Wiki](https://nixos.wiki/)
- [Search Packages](https://search.nixos.org/)

## Related

- [chezmoi.md](chezmoi.md) - Dotfile management with Chezmoi
- [python.md](python.md) - Python development with Nix
