{ config, pkgs, lib, inputs, username, ... }:
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
    
    # Mise configuration
    MISE_DEFAULT_TOOL_VERSIONS_FILENAME = ".mise.toml";
    MISE_DEFAULT_CONFIG_FILENAME = ".mise.toml";
    
    # Add secret environment variables when secrets are configured:
    # OPENAI_API_KEY = config.sops.secrets."api-keys".value;
    # GITHUB_TOKEN = config.sops.secrets."api-keys".value;
  };

  home.packages = with pkgs; [
    # Version control
    git
    
    # Editors
    neovim
    
    # Terminal multiplexer
    tmux
    
    # Shell enhancements
    fzf
    zoxide
    direnv
    
    # System utilities
    coreutils
    gnused
    gawk
    findutils
    
    # macOS specific
    mas
    
    # Nix-specific tools
    sops
    age
    
    # Tool management
    mise
    
    # Shell integration
    scmpuff
    fasd
    
    # Your custom tools
    cx  # comma replacement
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
    
    ignores = [
      # macOS
      ".DS_Store"
      ".AppleDouble"
      ".LSOverride"
      "._*"
      
      # Editor swap files
      "*.swp"
      "*.swo"
      "*~"
      
      # mise-specific
      ".mise.local.toml"
      ".mise/cache/"
      
      # Direnv
      ".direnv/"
      ".envrc.local"
      
      # IDE files
      ".idea/"
      ".vscode/"
      "*.sublime-*"
      
      # Logs and databases
      "*.log"
      "*.sqlite"
      
      # Environment files
      ".env.local"
      ".env.*.local"
    ];
    
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


  programs.mise = {
    enable = true;
    enableZshIntegration = true;
    
    # Global defaults - loose constraints that projects can override
    globalConfig = {
      tools = {
        # Language runtimes with flexible versions
        node = "lts";        # Currently v22 LTS (v22.17.0)
        python = "3.12";     # Recommended stable (3.11 also good)
        go = "1.24";         # Latest stable (1.24.5)
        rust = "stable";     # Latest stable (1.88.0)
        
        # Global CLI tools
        "cargo:eza" = "latest";        # Modern ls replacement
        "cargo:vivid" = "latest";      # LS_COLORS generator
        
        # npm packages
        "npm:@anthropic-ai/claude-code" = "1.0";  # Claude Code CLI
        "npm:ccusage" = "latest";                  # Claude usage tracking
        "npm:@google/gemini-cli" = "latest";       # Gemini CLI
        
        # iOS/macOS development
        tuist = "latest";                          # Xcode project generation
      };
    };
    
    settings = {
      # Support legacy version files from other tools
      legacy_version_file = true;  # .nvmrc, .python-version, etc.
      
      # Don't auto-install missing tools (explicit is better)
      experimental = false;
      
      # Disable specific tools if needed
      disable_tools = [];
      
      # Trusted configuration files (avoid security prompts)
      trusted_config_paths = [
        "~/.config/mise"
        "~/Projects"  # Adjust to your project root
      ];
    };
  };

  home.file = {
    # nvim config is symlinked manually via activation script to allow writes
    ".config/ghostty/config".source = ../dotfiles/ghostty/config;
    
    # Claude commands directory
    ".claude/commands" = {
      source = ../dotfiles/claude-commands;
      recursive = true;
    };
  };
  
  # Create manual symlinks for directories that need write access
  home.activation = {
    nvimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      if [ -L "$HOME/.config/nvim" ] || [ -e "$HOME/.config/nvim" ]; then
        rm -rf "$HOME/.config/nvim"
      fi
      ln -sf "$HOME/.config/nix/dotfiles/nvim" "$HOME/.config/nvim"
    '';
    
    claudeConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      mkdir -p "$HOME/.claude"
      if [ -L "$HOME/.claude/CLAUDE.md" ] || [ -e "$HOME/.claude/CLAUDE.md" ]; then
        rm -f "$HOME/.claude/CLAUDE.md"
      fi
      ln -sf "$HOME/.config/nix/dotfiles/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    '';
  };
}
