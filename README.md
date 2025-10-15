# Multi-Platform Nix Configuration

A unified, declarative Nix configuration that works on both macOS (via nix-darwin) and Android (via nix-on-droid).

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
├── common/            # Shared configurations
│   ├── home.nix       # Common home-manager config
│   ├── packages.nix   # Shared package list
│   └── programs.nix   # Shared program configs
├── darwin/            # macOS-specific configuration
│   ├── default.nix    # macOS system settings, services
│   └── home.nix       # macOS home overrides
├── droid/             # Android-specific configuration
│   ├── default.nix    # nix-on-droid config
│   └── home.nix       # Android home overrides
├── home/              # Legacy home configuration (for backward compatibility)
│   └── default.nix    # User packages, dotfiles
├── dotfiles/          # Application configs (symlinked by home-manager)
│   ├── nvim/          # Neovim configuration
│   ├── ghostty/       # Terminal emulator config (macOS only)
│   └── claude-commands/ # Custom Claude Code commands
├── pkgs/              # Custom packages
│   └── comma-headless.nix # cx tool
└── zsh/               # Zsh configuration with platform detection
    ├── default.nix    # Zsh system config
    └── interactiveInit.zsh
```

## Technology Stack

### macOS
- **nix-darwin**: System-level macOS configuration
- **Homebrew**: GUI application installation (managed by nix-darwin)

### Android
- **nix-on-droid**: Android/Termux Nix configuration
- **Termux**: Android terminal emulator

### Both Platforms
- **home-manager**: User environment and dotfile management
- **Language Runtimes**: Installed globally via Nix (Node.js 22)
- **npm Global Packages**: Installed to `~/.npm-global` via home-manager activation scripts

## Key Design Decisions

### Language Toolchains

Language runtimes are installed globally via Nix:

- Node.js 22
- Python 3.12
- Go 1.24
- Rust (via rustup)

For project-specific versions, use `nix develop` shells or direnv.

### NPM Global Packages

To get bleeding-edge npm packages while maintaining declarative configuration, we use home-manager activation scripts that run `npm install -g` to `~/.npm-global/bin` on every rebuild. This gives us:

- Latest versions from npm registry
- Declarative package list in `home/default.nix`
- No need to manually manage global packages

Packages installed this way:

- `@anthropic-ai/claude-code`
- `ccusage`
- `@google/gemini-cli`
- `opencode-ai`
- `repomix`
- `@steipete/poltergeist`
- `@openai/codex`

### Dotfile Management

Changes to files in `~/.config/nvim` modify the Git repo directly due to symlinks. Commit these changes periodically to keep your configuration synchronized.

## Daily Usage

### System Management

#### macOS
```bash
# Rebuild system
sudo darwin-rebuild switch --flake ~/.config/nix

# Update flake inputs and rebuild
cd ~/.config/nix && nix flake update && sudo darwin-rebuild switch --flake .
```

#### Android (nix-on-droid)
```bash
# Rebuild system
nix-on-droid switch --flake ~/.config/nix

# Update flake inputs and rebuild
cd ~/.config/nix && nix flake update && nix-on-droid switch --flake .
```

**Important**: Always `git add` new files before rebuilding (nix flakes only see tracked files)

### Development Tools

```bash
# Enter dev shell with common tools (jq, ripgrep, fd, etc.)
nix develop

# Run tools on-demand without installing
cx <tool>  # e.g., cx wget, cx htop
```

### Adding Applications

- **GUI Apps**: Edit `darwin/default.nix` (Homebrew casks) or `home/default.nix` (Mac App Store)
- **CLI Tools**: Add to `home.packages` in `home/default.nix`
- **npm Packages**: Add to the activation script in `home/default.nix`

## Bootstrap Process

### macOS (New Machine)

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

### Android (nix-on-droid)

1. **Install nix-on-droid** from F-Droid

2. **Clone Repository**:
   ```bash
   git clone <your-repo-url> ~/.config/nix
   ```

3. **Build and Activate**:
   ```bash
   cd ~/.config/nix
   nix-on-droid switch --flake .
   ```

## Important Notes

### Both Platforms
- **Git**: New files must be tracked (`git add`) before rebuilding, as Nix flakes only see tracked files
- **npm globals**: Managed automatically via activation scripts, updated on every rebuild
- **Shared aliases**: Both platforms support `rebuild` and `update` aliases (automatically detect platform)

### macOS-Specific
- **Homebrew**: If you have an existing Homebrew installation, uninstall it first to prevent conflicts
- **Chrome history search**: Available via `ch` function

### Android-Specific
- **Home directory**: Located at `/data/data/com.termux.nix/files/home`
- **Terminal**: Uses Termux instead of Ghostty
- **No GUI apps**: Only CLI tools are available
