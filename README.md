# macOS Nix Configuration

A declarative Nix configuration for macOS, built on nix-darwin and home-manager.

## Philosophy

This configuration follows a **"minimal-install, maximal-nix-run"** paradigm:

- **Install-Light**: Only essential tools in global PATH (git, nvim, tmux, etc.)
- **Declarative First**: All configuration managed through Nix files
- **Application-Owned Config**: Apps own their config files, Nix just symlinks them
- **Run on Demand**: Use `cx <tool>` for one-off commands without global installation

## Repository Structure

```
~/.config/nix/
├── flake.nix          # Main entry point, defines inputs and system
├── common/            # Shared configuration
│   ├── home.nix       # Common home-manager config
│   ├── packages.nix   # Shared package list
│   └── programs.nix   # Shared program configs
├── darwin/            # macOS-specific configuration
│   ├── default.nix    # macOS system settings, services
│   └── home.nix       # macOS home overrides
├── dotfiles/          # Application configs (symlinked by home-manager)
│   ├── nvim/          # Neovim configuration
│   ├── ghostty/       # Terminal emulator config
│   └── claude-commands/ # Custom Claude Code commands
├── pkgs/              # Custom packages
│   └── comma-headless.nix # cx tool
└── zsh/               # Zsh configuration
    ├── default.nix    # Zsh system config
    └── interactiveInit.zsh
```

## Technology Stack

- **nix-darwin**: System-level macOS configuration
- **home-manager**: User environment and dotfile management
- **Homebrew**: GUI application installation (managed by nix-darwin)
- **Language Runtimes**: Installed globally via Nix (Node.js 24)
- **npm Global Packages**: Installed to `~/.npm-global` via home-manager activation scripts

## Key Design Decisions

### Language Toolchains

Language runtimes are installed globally via Nix (Node.js, Rust via rustup, Python via uv, Zig, etc.). For project-specific versions, use `nix develop` shells or direnv.

### NPM Global Packages

To get bleeding-edge npm packages while maintaining declarative configuration, we use home-manager activation scripts that run `npm install -g` to `~/.npm-global/bin` on every rebuild. This gives us:

- Latest versions from npm registry
- Declarative package list in `common/home.nix`
- No need to manually manage global packages

### Dotfile Management

`~/.config/nvim` and `~/.claude/CLAUDE.md` are `mkOutOfStoreSymlink`s pointing into this repo, so editing them modifies the Git repo directly. Commit these changes periodically to keep your configuration synchronized.

## Daily Usage

### System Management

```bash
# Rebuild system
sudo darwin-rebuild switch --flake ~/.config/nix

# Update flake inputs and rebuild
cd ~/.config/nix && nix flake update && sudo darwin-rebuild switch --flake .
```

**Important**: Always `git add` new files before rebuilding (nix flakes only see tracked files)

### Development Tools

```bash
# Enter dev shell with common tools (jq, ripgrep, fd, etc.)
nix develop

# Format Nix files
nix fmt

# Run tools on-demand without installing
cx <tool>  # e.g., cx wget, cx htop
```

### Adding Applications

- **GUI Apps**: Edit `darwin/default.nix` (Homebrew casks and Mac App Store)
- **CLI Tools**: Add to `common/packages.nix`
- **npm Packages**: Add to the activation script in `common/home.nix`

## Bootstrap Process (New Machine)

1. **Install Nix (Determinate Systems)**:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. **Log in to Mac App Store**: Manually authenticate for `mas-cli`

3. **Clone Repository**:
   ```bash
   git clone <your-repo-url> ~/.config/nix
   ```

4. **Build and Activate**:
   ```bash
   cd ~/.config/nix
   sudo darwin-rebuild switch --flake .
   ```

5. **Log out and log back in** to ensure the new environment is fully active

## Important Notes

- **Git**: New files must be tracked (`git add`) before rebuilding, as Nix flakes only see tracked files
- **npm globals**: Managed automatically via activation scripts, updated on every rebuild
- **Homebrew**: If you have an existing Homebrew installation, uninstall it first to prevent conflicts. Rebuilds no longer auto-update/upgrade Homebrew — run `brew update && brew upgrade` explicitly when you want new versions.
- **Chrome history search**: Available via `ch` function
