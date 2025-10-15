{ config, pkgs, lib, inputs, username, ... }:

{
  imports = [
    ../common/home.nix
  ];

  # Android/Termux home directory
  home.homeDirectory = "/data/data/com.termux.nix/files/home";

  # Android-specific session variables
  home.sessionVariables = {
    BROWSER = "termux-open-url";
  };

  # Android-specific configurations
  # No Ghostty on Android, terminal is handled by Termux
}