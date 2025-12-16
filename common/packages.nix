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
  uv            # Python package manager

  # CLI tools
  eza           # Modern ls replacement
  vivid         # LS_COLORS generator
  devenv        # Development environment manager
  ripgrep       # Fast grep alternative (rg)
  rustup        # Rust toolchain manager

  # Build tools
  cmake
]