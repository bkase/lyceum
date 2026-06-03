{ pkgs, ... }:

with pkgs; [
  # Version control
  git
  jujutsu      # Git-compatible VCS (jj)

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
  mosh          # Mobile shell (client and server)

  # Language runtimes
  nodejs_24
  uv            # Python package manager

  # CLI tools
  eza           # Modern ls replacement
  vivid         # LS_COLORS generator
  devenv        # Development environment manager
  ripgrep       # Fast grep alternative (rg)
  rustup        # Rust toolchain manager
  zig

  # Build tools
  cmake
  xcodegen
]
