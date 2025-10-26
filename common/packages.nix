{ pkgs, ... }:

with pkgs; [
  # Version control
  git

  # Editors
  neovim

  # Terminal multiplexer
  tmux
  zellij

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

  # CLI tools
  eza           # Modern ls replacement
  vivid         # LS_COLORS generator
  devenv        # Development environment manager
]