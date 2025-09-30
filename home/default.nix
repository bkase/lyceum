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

  home.sessionPath = [
    "$HOME/.local/bin"
  ];

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
    
    # Nix-specific tools
    sops
    age
    
    # Tool management
    mise
    
    # File watching
    watchman
    
    # Shell integration
    scmpuff
    fasd
    
    # Networking
    cloudflared
    
    # Your custom tools
    cx  # comma replacement
  ];

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

  programs.zsh = {
    enable = true;
    initContent = ''
      # Add ~/.local/bin to PATH
      export PATH="$HOME/.local/bin:$PATH"
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
        node = "lts";
        python = "3.12";     # Recommended stable
        go = "1.24";         # Latest stable
        rust = "stable";     # Latest stable
        
        # Global CLI tools
        "cargo:eza" = "latest";        # Modern ls replacement
        "cargo:vivid" = "latest";      # LS_COLORS generator
        
        # npm packages
        "npm:pnpm" = "latest";                      # Fast, disk space efficient package manager
        "npm:@anthropic-ai/claude-code" = "latest";  # Claude Code CLI
        "npm:ccusage" = "latest";                  # Claude usage tracking
        "npm:@google/gemini-cli" = "latest";       # Gemini CLI
        "npm:opencode-ai" = "latest";              # OpenCode AI
        "npm:repomix" = "latest";                  # Repository to single file converter
        "npm:@steipete/poltergeist" = "latest";    # Website automation tool
        "npm:@openai/codex" = "latest";            # OpenAI Codex CLI
        
        # iOS/macOS development
        tuist = "latest";                          # Xcode project generation
      };
    };
    
    settings = {
      # Support legacy version files from other tools
      legacy_version_file = true;  # .nvmrc, .python-version, etc.
      
      # Enable idiomatic version files for Python
      idiomatic_version_file_enable_tools = ["python"];
      
      # Don't auto-install missing tools (explicit is better)
      experimental = false;
      
      # Disable specific tools if needed
      disable_tools = [];
      
      # Trusted configuration files (avoid security prompts)
      trusted_config_paths = [
        "~/.config/mise"
        "~/Documents"  # Adjust to your project root
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

    # a4 development shim
    ".local/bin/a4" = {
      source = ../dotfiles/a4;
      executable = true;
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
