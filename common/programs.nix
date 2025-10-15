{ pkgs, lib, ... }:

{
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
    # Using initExtra for now (initContent requires newer home-manager)
    initExtra = ''
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
}