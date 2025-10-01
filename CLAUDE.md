# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a declarative macOS configuration using Nix, nix-darwin, and home-manager. The system follows a "minimal-install, maximal-nix-run" paradigm where most tools are run on-demand rather than installed globally.

## Key Commands

### System Management
- **Rebuild system**: `sudo darwin-rebuild switch --flake ~/.config/nix`
- **Update flake inputs**: `nix flake update`
- **Update and rebuild**: `cd ~/.config/nix && nix flake update && sudo darwin-rebuild switch --flake .`
- **Important**: Always `git add` new files before rebuilding, as nix flakes only see tracked files

### Development Shell
- **Enter dev shell with tools**: `nix develop` (provides jq, ripgrep, fd, etc.)
- **Run tools on-demand**: `cx <tool>` (e.g., `cx wget`, `cx htop`)

## Architecture

### Repository Structure
```
~/.config/nix/
├── flake.nix          # Main entry point, defines inputs and system
├── darwin/            # System-level configuration
│   └── default.nix    # macOS system settings, services
├── home/              # User-level configuration
│   └── default.nix    # User packages, dotfiles, npm globals
├── dotfiles/          # Application configs (symlinked by home-manager)
│   ├── nvim/          # Neovim configuration
│   ├── ghostty/       # Terminal emulator config
│   └── claude-commands/ # Custom Claude Code commands
└── zsh/               # Zsh interactive init
    └── interactiveInit.zsh
```

### Key Design Principles

1. **Install-Light**: Only essential tools in global PATH (git, nvim, tmux, etc.)
2. **Declarative First**: All configuration managed through Nix files
3. **Application-Owned Config**: Apps own their config files, Nix just symlinks
4. **Run on Demand**: Use `cx` for one-off commands without global installation

### Technology Stack

- **nix-darwin**: System-level macOS configuration
- **home-manager**: User environment and dotfile management
- **Homebrew**: GUI application installation (managed by nix-darwin)
- **npm global packages**: Installed to `~/.npm-global` via home-manager activation scripts

## Important Notes

1. **Dotfile Changes**: Changes to files in `~/.config/nvim` modify the Git repo directly due to symlinks. Commit these changes periodically.

2. **Adding GUI Apps**: Edit `darwin/default.nix` (Homebrew casks) or `home/default.nix` (Mac App Store apps).

3. **Language Toolchains**: Language runtimes (Node.js, Python, Go, Rust) are installed globally via Nix. For project-specific versions, use `nix develop` shells or direnv.

4. **npm Global Packages**: Managed declaratively via activation scripts in `home/default.nix`. They're installed to `~/.npm-global/bin` and updated on every rebuild. To add a package, add it to the activation script's npm install command.
