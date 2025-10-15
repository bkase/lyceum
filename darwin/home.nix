{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ../common/home.nix
  ];

  # macOS-specific home directory
  home.homeDirectory = "/Users/${username}";

  # macOS-specific session variables
  home.sessionVariables = {
    BROWSER = "open";
  };

  # macOS-specific files
  home.file = {
    # Ghostty config (macOS only)
    ".config/ghostty/config".source = ../dotfiles/ghostty/config;
  };
}