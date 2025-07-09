{ config, pkgs, inputs, username, hostname, ... }:

{
  users.users.${username} = {
    home = "/Users/${username}";
    shell = pkgs.zsh;
  };

  nix = {
    package = pkgs.nix;
    
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ username ];
      warn-dirty = false;
      auto-optimise-store = true;
    };
    
    gc = {
      automatic = true;
      interval = { Day = 7; };
      options = "--delete-older-than 30d";
    };
  };

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  services.nix-daemon.enable = true;

  programs.zsh.enable = true;

  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";
      upgrade = true;
    };
    
    taps = [];
    brews = [];
    casks = [];
  };

  services.tailscale.enable = true;

  # XCode Command Line Tools
  # Note: XCode itself must be installed manually from the App Store
  # programs.xcode.enable = true;  # Uncomment if needed

  system = {
    stateVersion = 5;
    
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";
        ApplePressAndHoldEnabled = false;
        KeyRepeat = 2;
        InitialKeyRepeat = 10;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      dock = {
        autohide = true;
        orientation = "bottom";
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

  security.pam.enableSudoTouchIdAuth = true;
}