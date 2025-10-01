# Declarative macOS Configuration

A minimal, declarative macOS environment using Nix, nix-darwin, and home-manager.

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
├── darwin/            # System-level configuration
│   └── default.nix    # macOS system settings, services
├── home/              # User-level configuration
│   └── default.nix    # User packages, dotfiles
├── dotfiles/          # Application configs (symlinked by home-manager)
│   ├── nvim/          # Neovim configuration
│   ├── ghostty/       # Terminal emulator config
│   └── claude-commands/ # Custom Claude Code commands
└── zsh/               # Zsh interactive init
    └── interactiveInit.zsh
```

## Technology Stack

- **nix-darwin**: System-level macOS configuration
- **home-manager**: User environment and dotfile management
- **Homebrew**: GUI application installation (managed by nix-darwin)
- **Language Runtimes**: Installed globally via Nix (Node.js, Python, Go, Rust)
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

```bash
# Rebuild system
sudo darwin-rebuild switch --flake ~/.config/nix

# Update flake inputs and rebuild
cd ~/.config/nix && nix flake update && sudo darwin-rebuild switch --flake .

# Important: Always git add new files before rebuilding
# (nix flakes only see tracked files)
```

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

- **Homebrew**: If you have an existing Homebrew installation, uninstall it first to prevent conflicts
- **Git**: New files must be tracked (`git add`) before rebuilding, as Nix flakes only see tracked files
- **npm globals**: Managed automatically via activation scripts, updated on every rebuild
