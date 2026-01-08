# in configuration.nix
{ pkgs, lib, inputs, ... }:
{

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.droid-sans-mono
			nerd-fonts.monaspace
    ];

    # enable touch id based sudo authentication
    security.pam.services.sudo_local.touchIdAuth = true;
    # allow installation of apps that aren't "free"
    nixpkgs.config.allowUnfree = true;

    # List packages installed in system profile. To search by name, run:
    # $ nix-env -qaP | grep wget
    environment.systemPackages =
    [
        pkgs.terraform
				pkgs.neovim
        pkgs.chezmoi
        pkgs.fzf
				pkgs.navi
        pkgs.argocd
        pkgs.zoxide
        pkgs.go
        pkgs.git
        pkgs.git-lfs
        pkgs.python314
        pkgs.kubectl
        pkgs.jq
        pkgs.zsh-completions
        pkgs.yq
        pkgs.bat
        pkgs.nodejs_25
        pkgs.hugo
        pkgs.uv
        pkgs.gh
        pkgs.kubernetes-helm
        pkgs.javaPackages.compiler.openjdk25
        pkgs.kind
        pkgs.krew
        pkgs.kubeconform
        pkgs.kubecolor
        pkgs.k9s
        pkgs.caffeine
        pkgs.asdf-vm
        pkgs.doppler
        pkgs.aerospace
        pkgs.tree
        pkgs.act
        pkgs.lf
        pkgs.htop
        #pkgs.ghostty-bin
				pkgs.itsycal
        #pkgs.ice-bar
        pkgs.starship
        pkgs.zinit
        pkgs.bash-completion
        pkgs.eza
        pkgs.hstr
        pkgs.pay-respects
        pkgs.go
    ];

    # Necessary for using flakes on this system.
    nix.settings.experimental-features = "nix-command flakes";

    # Enable alternative shell support in nix-darwin.
    # programs.fish.enable = true;

    # Set Git commit hash for darwin-version.
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    system.stateVersion = 6;

    # The platform the configuration will be used on.
    nixpkgs.hostPlatform = "aarch64-darwin";
}
