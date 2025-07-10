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
- **Run tools on-demand**: `nix run nixpkgs#<tool>` (e.g., `nix run nixpkgs#htop`)

### Secret Management
- **Edit encrypted env vars**: `sops secrets/env.sops`
- **Create age key**: `age-keygen -o ~/.config/sops/age/keys.txt`

## Architecture

### Repository Structure
```
~/.config/nix/
├── flake.nix          # Main entry point, defines inputs and system
├── darwin/            # System-level configuration
│   └── default.nix    # macOS system settings, services
├── home/              # User-level configuration  
│   └── default.nix    # User packages, dotfiles, secrets
├── dotfiles/          # Application configs (symlinked by home-manager)
│   └── nvim/          # Neovim configuration
└── secrets/           # Encrypted files (sops-nix)
    └── env.sops       # Encrypted environment variables
```

### Key Design Principles

1. **Install-Light**: Only essential tools in global PATH (git, nvim, tmux, etc.)
2. **Declarative First**: All configuration managed through Nix files
3. **Secrets Separation**: Sensitive data encrypted with sops-nix
4. **Application-Owned Config**: Apps own their config files, Nix just symlinks

### Technology Stack

- **nix-darwin**: System-level macOS configuration
- **home-manager**: User environment and dotfile management
- **sops-nix**: Encrypted secret management
- **mise**: Language toolchain management (Node.js, Python, etc.)
- **Homebrew**: GUI application installation (managed by nix-darwin)

## Important Notes

1. **Dotfile Changes**: Changes to files in `~/.config/nvim` modify the Git repo directly due to symlinks. Commit these changes periodically.

2. **Adding GUI Apps**: Edit `home/default.nix` to add to `home.mas.apps` (App Store) or `homebrew.casks` in `darwin/default.nix`.

3. **Language Toolchains**: Use `mise` for project-specific language versions instead of installing globally.

4. **Secrets**: Never commit unencrypted secrets. Always use sops to encrypt before committing.