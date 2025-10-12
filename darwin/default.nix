{ config, pkgs, inputs, username, hostname, ... }:

{
  # Set primary user for system defaults
  system.primaryUser = username;
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  # Disable nix-darwin's Nix management for Determinate Nix
  nix.enable = false;

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  # nix-daemon is now managed automatically by nix-darwin


  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    
    taps = [];
    brews = [];
    casks = [
      "lm-studio"
      "torguard"
      "claude"
      "google-chrome"
      "arq"
      "vibetunnel"
      "ghostty"
      "iina"
      "multipass"
      "xquartz"
    ];
    
    masApps = {
      "Tailscale" = 1475387142;
    };
  };

  services.tailscale.enable = true;

  system = {
    stateVersion = 5;

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = null;
        ApplePressAndHoldEnabled = false;
        "com.apple.swipescrolldirection" = false;
        KeyRepeat = 1;
        InitialKeyRepeat = 12;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      dock = {
        autohide = true;
        orientation = "left";
        show-recents = false;
        tilesize = 48;
        mru-spaces = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
      };
    };
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
