{ config, pkgs, inputs, username, ... }:

{
  home = {
    username = username;
    homeDirectory = "/Users/${username}";
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    enable = true;
    # defaultSopsFile = ../secrets/env.sops;  # Uncomment when secrets exist
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
    
    # Define secret sources when you have them:
    # secrets."api-keys" = { 
    #   source = ../secrets/env.sops; 
    #   format = "dotenv"; 
    # };
    # secrets."gh-hosts" = {
    #   source = ../secrets/gh/hosts.yml;
    #   target = "${config.home.homeDirectory}/.config/gh/hosts.yml";
    # };
  };

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
    starship
    direnv
    sops
    age
    mise
    coreutils
    gnused
    gawk
    findutils
    mas  # Mac App Store CLI
  ];

  # Mac App Store applications
  # home.mas = {
  #   enable = true;
  #   apps = [
  #     # Add your Mac App Store app IDs here
  #     # Example: { id = 1234567890; name = "AppName"; }
  #   ];
  # };

  # Homebrew Casks (GUI applications)
  # home.casks = [
  #   # Add your Homebrew cask apps here
  #   # Example: "visual-studio-code"
  #   # "1password"
  #   # "slack"
  # ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    initExtra = ''
      # Zoxide
      eval "$(zoxide init zsh)"
      
      # Starship
      eval "$(starship init zsh)"
      
      # Direnv
      eval "$(direnv hook zsh)"
      
      # Mise
      eval "$(mise activate zsh)"
      
      # FZF
      source ${pkgs.fzf}/share/fzf/completion.zsh
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    '';
    
    shellAliases = {
      ll = "ls -la";
      la = "ls -la";
      l = "ls -l";
      g = "git";
      v = "nvim";
      rebuild = "darwin-rebuild switch --flake ~/.config/nix";
      update = "cd ~/.config/nix && nix flake update && rebuild";
    };
  };

  programs.git = {
    enable = true;
    userName = "bkase";
    userEmail = "bkase@example.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      rebase.autoStash = true;
      core.editor = "nvim";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      format = "$all$character";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
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
    icons = true;
  };

  home.file = {
    ".config/nvim".source = ../dotfiles/nvim;
  };
}