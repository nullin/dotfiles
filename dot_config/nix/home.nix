{ config, pkgs, ... }:

{
  home.stateVersion = "25.11";

  # User-specific packages
  #home.packages = with pkgs; [
  #  # Add user-specific packages here
  #];

  # Configure programs
  #programs.git = {
  #  enable = true;
  #  userName = "Your Name";
  #  userEmail = "your.email@example.com";
  #};

  #programs.zsh = {
  #  enable = true;
  #  # Add zsh configuration here
  #};

  programs.home-manager.enable = true;
}