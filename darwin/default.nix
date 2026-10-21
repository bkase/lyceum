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
      # Keep `darwin-rebuild switch` reproducible: don't refresh taps or bump
      # versions on every rebuild. Run `brew update && brew upgrade` explicitly.
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";
      extraFlags = [ "--force-cleanup" ];
    };
    
    taps = [
      "neurosnap/tap"
      "steipete/tap"
      # aerospace lives in this third-party tap. It is not an official cask, so
      # Homebrew requires the tap to be trusted (`brew trust nikitabobko/tap`,
      # stored in ~/.homebrew/trust.json) before `brew bundle` will load it.
      "nikitabobko/tap"
    ];
    brews = [
      "neurosnap/tap/zmx"
      "steipete/tap/crabbox"
    ];
    casks = [
      "lm-studio"
      "torguard"
      "google-chrome"
      "arq"
      "ghostty"
      "iina"
      "multipass"
      "xquartz"
      "codexbar"
      "obsidian"
      "claude"
      "vibetunnel"
      "nikitabobko/tap/aerospace"
    ];
    
    # Tailscale (App Store id 1475387142) is installed manually from the Mac App
    # Store, not declared in masApps. `mas` 6 detects installed apps via Spotlight;
    # this machine's Spotlight index does not cover /Applications, so brew bundle
    # thinks Tailscale is missing and hangs on `mas install`. Reinstate the masApps
    # entry once `mas list` shows Tailscale (e.g. after `sudo mdutil -E /`).
    masApps = { };
  };

  # Do not enable services.tailscale — the nix-darwin daemon conflicts with the
  # Tailscale GUI app.

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
