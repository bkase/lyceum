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

  # Networking
  cloudflared
  mosh          # Mobile shell (client and server)

  # Language runtimes
  nodejs_24
  bun           # JS runtime & package manager
  uv            # Python package manager

  # CLI tools
  eza           # Modern ls replacement
  vivid         # LS_COLORS generator
  devenv        # Development environment manager
  ripgrep       # Fast grep alternative (rg)
  rustup        # Rust toolchain manager
  zig
  ffmpeg        # Audio/video processing

  # Build tools
  cmake
  xcodegen
]
