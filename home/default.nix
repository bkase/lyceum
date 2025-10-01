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

    # Add secret environment variables when secrets are configured:
    # OPENAI_API_KEY = config.sops.secrets."api-keys".value;
    # GITHUB_TOKEN = config.sops.secrets."api-keys".value;
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
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

    # File watching
    watchman

    # Shell integration
    scmpuff
    fasd

    # Networking
    cloudflared

    # Language runtimes
    nodejs_22
    python312
    go_1_24
    rustup

    # CLI tools
    eza           # Modern ls replacement
    vivid         # LS_COLORS generator
    nodePackages.pnpm

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

    installGlobalNpmPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Install global npm packages to ~/.npm-global
      mkdir -p "$HOME/.npm-global"
      export PATH="${pkgs.nodejs_22}/bin:$PATH"
      $DRY_RUN_CMD npm install -g --prefix="$HOME/.npm-global" \
        @anthropic-ai/claude-code \
        ccusage \
        @google/gemini-cli \
        opencode-ai \
        repomix \
        @steipete/poltergeist \
        @openai/codex
    '';
  };
}
