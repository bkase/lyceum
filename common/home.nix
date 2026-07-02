{ config, pkgs, lib, inputs, username, ... }:

let
  cx = pkgs.callPackage ../pkgs/comma-headless.nix { };

  # Common packages shared between platforms
  commonPackages = import ./packages.nix { inherit pkgs; };

  # Zellij forgot plugin
  zellijForgotPlugin = pkgs.fetchurl {
    url = "https://github.com/karimould/zellij-forgot/releases/download/0.4.2/zellij_forgot.wasm";
    sha256 = "sha256-MRlBRVGdvcEoaFtFb5cDdDePoZ/J2nQvvkoyG6zkSds=";
  };
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
    SUMMARIZE_ONNX_PARAKEET_CMD = ''["parakeet-mlx-wrapper", "{input}"]'';
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

    # Editable, in-place symlinks into the repo so edits land in git directly.
    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/nix/dotfiles/nvim";
    ".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink
        "${config.home.homeDirectory}/.config/nix/dotfiles/claude/CLAUDE.md";

    # a4 development shim
    ".local/bin/a4" = {
      source = ../dotfiles/a4;
      executable = true;
    };

    # parakeet-mlx wrapper for summarize transcriber
    ".local/bin/parakeet-mlx-wrapper" = {
      source = ../dotfiles/parakeet-mlx-wrapper;
      executable = true;
    };

    # Bun config: defer installs of packages newer than 7 days (supply chain protection)
    ".bunfig.toml".text = ''
      [install]
      minimumReleaseAge = 604800
    '';

    # Zellij config
    ".config/zellij/config.kdl".source = ../dotfiles/zellij/config.kdl;

    # Zellij plugins
    ".config/zellij/plugins/zellij_forgot.wasm".source = zellijForgotPlugin;
  };

  # Common activation scripts
  home.activation = {
    installGlobalNpmPackages = lib.hm.dag.entryAfter ["writeBoundary"] ''
      # Install global npm packages to ~/.npm-global
      mkdir -p "$HOME/.npm-global"
      export PATH="${pkgs.nodejs_24}/bin:$PATH"
      $DRY_RUN_CMD npm install -g --prefix="$HOME/.npm-global" \
        npm@latest \
        @anthropic-ai/claude-code \
        @google/gemini-cli \
        @mariozechner/pi-coding-agent \
        repomix \
        @steipete/poltergeist \
        @openai/codex \
        @steipete/summarize \
        acpx
    '';

    # Ensure ~/.npmrc has min-release-age=7 (supply chain protection) without
    # clobbering other lines (e.g. auth tokens added by `npm login`).
    npmrcMinReleaseAge = lib.hm.dag.entryAfter ["writeBoundary"] ''
      NPMRC="$HOME/.npmrc"
      touch "$NPMRC"
      if ${pkgs.gnugrep}/bin/grep -q "^min-release-age=" "$NPMRC"; then
        ${pkgs.gnused}/bin/sed -i.bak "s/^min-release-age=.*/min-release-age=7/" "$NPMRC"
        rm -f "$NPMRC.bak"
      else
        echo "min-release-age=7" >> "$NPMRC"
      fi
    '';
  };
}
