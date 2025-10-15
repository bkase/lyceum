{ config, pkgs, lib, inputs, username, ... }:

let
  cx = pkgs.callPackage ../pkgs/comma-headless.nix { };

  # Common packages shared between platforms
  commonPackages = import ./packages.nix { inherit pkgs; };
in

{
  imports = [
    ./programs.nix
  ];

  home = {
    username = username;
    stateVersion = "24.05";
  };

  programs.home-manager.enable = true;

  home.sessionVariables = {
    EDITOR = "nvim";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.npm-global/bin"
  ];

  home.packages = commonPackages ++ [ cx ];

  home.file = {
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

  # Common activation scripts
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