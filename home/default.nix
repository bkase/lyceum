{ config, pkgs, inputs, username, ... }:
let
  cx = pkgs.callPackage ../pkgs/comma-headless.nix { };
in

{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  # Temporarily disabled sops while migrating to unstable
  # imports = [
  #   inputs.sops-nix.homeManagerModules.sops
  # ];

  # sops = {
  #   enable = true;
  #   # defaultSopsFile = ../secrets/env.sops;  # Uncomment when secrets exist
  #   age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  #   
  #   # Define secret sources when you have them:
  #   # secrets."api-keys" = { 
  #   #   source = ../secrets/env.sops; 
  #   #   format = "dotenv"; 
  #   # };
  #   # secrets."gh-hosts" = {
  #   #   source = ../secrets/gh/hosts.yml;
  #   #   target = "${config.home.homeDirectory}/.config/gh/hosts.yml";
  #   # };
  # };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "open";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    
    # Add secret environment variables when secrets are configured:
    # OPENAI_API_KEY = config.sops.secrets."api-keys".value;
    # GITHUB_TOKEN = config.sops.secrets."api-keys".value;
  };

  home.packages = with pkgs; [
    git
    neovim
    tmux
    fzf
    zoxide
    direnv
    sops
    age
    mise
    coreutils
    gnused
    gawk
    findutils
    mas  # Mac App Store CLI
    scmpuff      # Git status helper
    fasd         # Quick access to files and directories
    vivid        # LS_COLORS generator
    comma        # Run software without installing
    cx           # Headless comma for Claude
  ];

  # Mac App Store applications
  # home.mas = {
  #   enable = true;
  #   apps = [
  #     # Add your Mac App Store app IDs here
  #     # Example: { id = 1234567890; name = "AppName"; }
  #   ];
  # };

  programs.git = {
    enable = true;
    userName = "bkase";
    userEmail = "brandernan@gmail.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autoStash = true;
      core.editor = "nvim";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.tmux = {
    enable = true;
    baseIndex = 1;
    escapeTime = 0;
    keyMode = "vi";
    mouse = true;
    terminal = "screen-256color";
    
    extraConfig = ''
      set-option -ga terminal-overrides ",xterm-256color:Tc"
      bind-key -n C-Left select-pane -L
      bind-key -n C-Right select-pane -R
      bind-key -n C-Up select-pane -U
      bind-key -n C-Down select-pane -D
    '';
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    git = true;
    icons = "auto";
  };

  home.file = {
    ".config/nvim".source = ../dotfiles/nvim;
    ".config/ghostty/config".source = ../dotfiles/ghostty/config;
  };
}
