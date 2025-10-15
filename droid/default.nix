{ config, lib, pkgs, ... }:

{
  # Set your username
  user.shell = "${pkgs.zsh}/bin/zsh";

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value!
  system.stateVersion = "24.05";

  # Basic system packages (minimal set, most packages in home-manager)
  environment.packages = with pkgs; [
    # Core utilities needed at system level
    coreutils
    procps
    psmisc
    which
    gnugrep
    gnused
    gawk
  ];

  # Terminal configuration
  terminal = {
    # You can customize font if needed
    # font = "...";
    colors = {
      background = "#1e1e2e";
      foreground = "#cdd6f4";
    };
  };

  # Time zone configuration
  time.timeZone = "America/Los_Angeles";

  # nix configuration
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    warn-dirty = false
  '';

  # Home-manager is configured through the flake
}