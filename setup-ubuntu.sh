#!/usr/bin/env bash
#
# Ubuntu Setup Script
# Ports the Nix-based zsh/neovim configuration to native Ubuntu
#
# Usage: ./setup-ubuntu.sh
#
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if command exists
has_cmd() { command -v "$1" &>/dev/null; }

# ============================================================================
# 1. APT PACKAGES
# ============================================================================
install_apt_packages() {
    log_info "Installing apt packages..."

    # Add fastfetch PPA
    if ! grep -q "zhangsongcui3371/fastfetch" /etc/apt/sources.list.d/*.list 2>/dev/null; then
        log_info "Adding fastfetch PPA..."
        sudo add-apt-repository -y ppa:zhangsongcui3371/fastfetch
    fi

    sudo apt update
    sudo apt install -y \
        zsh \
        zsh-syntax-highlighting \
        neovim \
        fzf \
        direnv \
        ripgrep \
        tmux \
        cmake \
        build-essential \
        curl \
        wget \
        unzip \
        fontconfig \
        fastfetch \
        lm-sensors

    log_success "Apt packages installed"
}

# ============================================================================
# 2. RUSTUP + CARGO PACKAGES (using binstall for pre-built binaries)
# ============================================================================
install_rust_tools() {
    log_info "Setting up Rust toolchain..."

    if ! has_cmd rustup; then
        log_info "Installing rustup..."
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
        source "$HOME/.cargo/env"
    else
        log_success "rustup already installed"
    fi

    # Ensure cargo is in PATH for this script
    export PATH="$HOME/.cargo/bin:$PATH"

    # Install cargo-binstall first (for fast pre-built binary installs)
    if ! has_cmd cargo-binstall; then
        log_info "Installing cargo-binstall..."
        curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
    else
        log_success "cargo-binstall already installed"
    fi

    log_info "Installing cargo packages via binstall (pre-built binaries)..."

    # eza - modern ls replacement
    if ! has_cmd eza; then
        log_info "Installing eza..."
        cargo binstall -y eza
    else
        log_success "eza already installed"
    fi

    # vivid - LS_COLORS generator
    if ! has_cmd vivid; then
        log_info "Installing vivid..."
        cargo binstall -y vivid
    else
        log_success "vivid already installed"
    fi

    # fd - modern find replacement (used by fzf)
    if ! has_cmd fd; then
        log_info "Installing fd-find..."
        cargo binstall -y fd-find
    else
        log_success "fd already installed"
    fi

    # zoxide - smarter cd
    if ! has_cmd zoxide; then
        log_info "Installing zoxide..."
        cargo binstall -y zoxide
    else
        log_success "zoxide already installed"
    fi

    # zellij - terminal multiplexer
    if ! has_cmd zellij; then
        log_info "Installing zellij..."
        cargo binstall -y zellij
    else
        log_success "zellij already installed"
    fi

    log_success "Cargo packages installed"
}

# ============================================================================
# 3. SCMPUFF (Git number shortcuts)
# ============================================================================
install_scmpuff() {
    log_info "Installing scmpuff..."

    if has_cmd scmpuff; then
        log_success "scmpuff already installed"
        return
    fi

    local version="0.6.0"
    local machine=$(uname -m)
    local arch
    case "$machine" in
        x86_64)  arch="amd64" ;;
        aarch64) arch="arm64" ;;
        armv6l)  arch="armv6" ;;
        armv7l)  arch="armv6" ;;  # fallback to armv6
        *)       log_error "Unsupported architecture: $machine"; return 1 ;;
    esac

    local tmp_dir=$(mktemp -d)
    local filename="scmpuff_${version}_linux_${arch}.tar.gz"
    local url="https://github.com/mroth/scmpuff/releases/download/v${version}/${filename}"

    cd "$tmp_dir"
    log_info "Downloading from $url"
    curl -sL "$url" -o "$filename"
    tar xzf "$filename"

    mkdir -p "$HOME/.local/bin"
    mv scmpuff "$HOME/.local/bin/"

    cd - > /dev/null
    rm -rf "$tmp_dir"

    log_success "scmpuff installed to ~/.local/bin"
}

# ============================================================================
# 4. PURE PROMPT (bkase's fork)
# ============================================================================
install_pure_prompt() {
    log_info "Installing Pure prompt (bkase fork)..."

    local pure_dir="$HOME/.zsh/pure"

    if [[ -d "$pure_dir" ]]; then
        log_info "Updating existing Pure prompt..."
        cd "$pure_dir"
        git pull
        cd - > /dev/null
    else
        mkdir -p "$HOME/.zsh"
        git clone https://github.com/bkase/pure.git "$pure_dir"
    fi

    log_success "Pure prompt installed to ~/.zsh/pure"
}

# ============================================================================
# 5. ZSH CONFIGURATION
# ============================================================================
setup_zsh_config() {
    log_info "Setting up zsh configuration..."

    # Backup existing .zshrc if it exists and is not empty
    if [[ -f "$HOME/.zshrc" && -s "$HOME/.zshrc" ]]; then
        local backup="$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
        cp "$HOME/.zshrc" "$backup"
        log_warn "Backed up existing .zshrc to $backup"
    fi

    # Write the main .zshrc
    cat > "$HOME/.zshrc" << 'ZSHRC_EOF'
# =============================================================================
# ZSH Configuration - Ported from Nix config
# =============================================================================

# -----------------------------------------------------------------------------
# PATH Setup
# -----------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.npm-global/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL" ]] && export PATH="$BUN_INSTALL/bin:$PATH"

# nvm setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# -----------------------------------------------------------------------------
# History
# -----------------------------------------------------------------------------
export HISTFILE=~/.zshistory
export HISTSIZE=100000
export SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# -----------------------------------------------------------------------------
# Fast Completion (regenerate once a day)
# -----------------------------------------------------------------------------
zcachedir="$HOME/.zcache"
[[ -d "$zcachedir" ]] || mkdir -p "$zcachedir"

_update_zcomp() {
    setopt local_options
    setopt extendedglob
    autoload -Uz compinit
    local zcompf="$1/zcompdump"
    local zcompf_a="$zcompf.augur"

    if [[ -e "$zcompf_a" && -f "$zcompf_a"(#qN.md-1) ]]; then
        compinit -C -d "$zcompf"
    else
        compinit -d "$zcompf"
        touch "$zcompf_a"
    fi
    if [[ -s "$zcompf" && (! -s "$zcompf.zwc" || "$zcompf" -nt "$zcompf.zwc") ]]; then
        [[ -e "$zcompf.zwc" ]] && mv -f "$zcompf.zwc" "$zcompf.zwc.old"
        zcompile -M "$zcompf" &!
    fi
}
_update_zcomp "$zcachedir"
unfunction _update_zcomp

# Bash completion compatibility
autoload -U +X bashcompinit && bashcompinit

# -----------------------------------------------------------------------------
# Pure Prompt
# -----------------------------------------------------------------------------
export PURE_PROMPT_SYMBOL="𝝺"
fpath+=("$HOME/.zsh/pure")
autoload -U promptinit && promptinit
prompt pure

# -----------------------------------------------------------------------------
# Syntax Highlighting
# -----------------------------------------------------------------------------
if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# LS_COLORS using vivid (gruvbox-light theme)
if command -v vivid &>/dev/null; then
    export LS_COLORS=$(vivid generate gruvbox-light)
fi

# -----------------------------------------------------------------------------
# Functions
# -----------------------------------------------------------------------------
calc() { awk "BEGIN { print $* }"; }
record_pwd() { pwd > /tmp/.cwd }

git_squash_second_with_initial() {
   SECOND=$1
   INITIAL=$2
   git checkout $SECOND
   git reset --soft $INITIAL
   git commit --amend -m "Initial commit"
   git tag initial
   git checkout master
   git rebase --onto initial $SECOND
   git tag -d initial
}

# Register hooks
autoload -U add-zsh-hook && add-zsh-hook chpwd record_pwd

# cd to the most recent place
touch /tmp/.cwd
[[ -s /tmp/.cwd ]] && cd "$(cat /tmp/.cwd)" 2>/dev/null || true

# -----------------------------------------------------------------------------
# Aliases
# -----------------------------------------------------------------------------
alias vi="nvim"
alias vim="nvim"
alias ls="eza --group-directories-first"
alias l="ls"
alias mv="mv -i"
alias cp="cp -i"
alias rm="rm -i"
alias archey="fastfetch --logo none --structure 'Title:OS:Host:Kernel:Uptime:Memory:Swap:Disk'"
alias c="clear && archey"
alias cls="clear && archey && ls"

# Git aliases
alias gs="scmpuff_status"
alias gc="git commit"
alias wlog="git log --decorate --oneline"
alias gl="git log --decorate"
alias ggp="git grep"
alias gcob="git checkout -b"
alias gps="git push"
alias grb="git rebase"
alias gsh="git show"
alias gcp="git cherry-pick"
alias gd="git diff"
alias gf="git fetch"
alias gcl="git clone"
alias gb="git branch"

# -----------------------------------------------------------------------------
# Tool Integrations
# -----------------------------------------------------------------------------

# scmpuff (git number shortcuts)
if command -v scmpuff &>/dev/null; then
    eval "$(scmpuff init -s)"
fi

# fzf
if command -v fzf &>/dev/null; then
    # Gruvbox Light color scheme for fzf
    export FZF_DEFAULT_OPTS="
        --color fg:#3c3836,bg:#fbf1c7,hl:#b57614,fg+:#3c3836,bg+:#ebdbb2,hl+:#b57614
        --color info:#076678,prompt:#665c54,spinner:#b57614,pointer:#076678,marker:#af3a03,header:#bdae93
    "

    # Use fd for fzf if available
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix'
    fi

    # fzf key bindings and completion
    if [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    fi
    if [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
        source /usr/share/doc/fzf/examples/completion.zsh
    fi
fi

# direnv
if command -v direnv &>/dev/null; then
    eval "$(direnv hook zsh)"
fi

# zoxide - smarter cd
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias j="z"  # jump to directory
fi

# -----------------------------------------------------------------------------
# Show system info on shell start
# -----------------------------------------------------------------------------
if command -v fastfetch &>/dev/null; then
    fastfetch --logo none
fi
ZSHRC_EOF

    log_success "Created ~/.zshrc"

    # Create .zprofile for login shell PATH setup
    cat > "$HOME/.zprofile" << 'ZPROFILE_EOF'
# ~/.zprofile - Login shell setup (runs before .zshrc for login shells)
# This ensures PATH is set for non-interactive login shells (e.g., ssh commands)

# Cargo
[[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Local bin
export PATH="$HOME/.local/bin:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
[[ -d "$BUN_INSTALL" ]] && export PATH="$BUN_INSTALL/bin:$PATH"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
ZPROFILE_EOF

    log_success "Created ~/.zprofile"
}

# ============================================================================
# 6. NEOVIM CONFIGURATION
# ============================================================================
setup_neovim() {
    log_info "Setting up Neovim..."

    local nvim_config="$HOME/.config/nvim"
    local nvim_source="$HOME/.config/nix/dotfiles/nvim"

    # Check if source exists
    if [[ ! -d "$nvim_source" ]]; then
        log_error "Neovim config source not found at $nvim_source"
        return 1
    fi

    # Check current state
    if [[ -L "$nvim_config" ]]; then
        local current_target=$(readlink "$nvim_config")
        if [[ "$current_target" == "$nvim_source" ]]; then
            log_success "Neovim config already correctly symlinked"
            return 0
        fi
        log_info "Removing old symlink pointing to $current_target"
        rm "$nvim_config"
    elif [[ -d "$nvim_config" ]]; then
        # It's a real directory - check if it's the same content
        if diff -q "$nvim_config/init.lua" "$nvim_source/init.lua" &>/dev/null; then
            log_info "Neovim config appears to be a copy, converting to symlink..."
            local backup="$nvim_config.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$nvim_config" "$backup"
            log_warn "Backed up existing nvim config to $backup"
        else
            log_warn "Existing nvim config differs from source"
            local backup="$nvim_config.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$nvim_config" "$backup"
            log_warn "Backed up existing nvim config to $backup"
        fi
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$nvim_config")"

    # Create symlink
    ln -sf "$nvim_source" "$nvim_config"

    log_success "Neovim config symlinked: $nvim_config -> $nvim_source"
    log_info "Run 'nvim' to trigger LazyVim plugin installation"
}

# ============================================================================
# 7. GIT CONFIGURATION
# ============================================================================
setup_git() {
    log_info "Setting up Git configuration..."

    # Only set if not already configured
    if [[ -z "$(git config --global user.name)" ]]; then
        git config --global user.name "bkase"
    fi
    if [[ -z "$(git config --global user.email)" ]]; then
        git config --global user.email "brandernan@gmail.com"
    fi

    git config --global init.defaultBranch main
    git config --global push.autoSetupRemote true
    git config --global pull.rebase true
    git config --global rebase.autoStash true
    git config --global core.editor nvim

    # Global gitignore
    local gitignore="$HOME/.gitignore_global"
    cat > "$gitignore" << 'EOF'
# macOS
.DS_Store
.AppleDouble
.LSOverride
._*

# Editor swap files
*.swp
*.swo
*~

# Direnv
.direnv/
.envrc.local

# IDE files
.idea/
.vscode/
*.sublime-*

# Logs and databases
*.log
*.sqlite

# Environment files
.env.local
.env.*.local
EOF

    git config --global core.excludesfile "$gitignore"

    log_success "Git configured"
}

# ============================================================================
# 8. ZELLIJ CONFIGURATION
# ============================================================================
setup_zellij() {
    log_info "Setting up Zellij configuration..."

    mkdir -p "$HOME/.config/zellij"

    cat > "$HOME/.config/zellij/config.kdl" << 'EOF'
// Zellij Configuration with Gruvbox Light theme

// Theme configuration
theme "gruvbox-light"

themes {
    gruvbox-light {
        fg "#3c3836"      // fg0
        bg "#fbf1c7"      // bg0
        black "#fbf1c7"   // bg0
        red "#cc241d"     // red
        green "#98971a"   // green
        yellow "#d79921"  // yellow
        blue "#458588"    // blue
        magenta "#b16286" // purple
        cyan "#689d6a"    // aqua
        white "#3c3836"   // fg0
        orange "#d65d0e"  // orange
    }
}

// General settings
default_shell "zsh"
pane_frames false
simplified_ui false
default_layout "compact"
mouse_mode true
copy_on_select true

// Keybindings
keybinds {
    normal {
        // Unbind Ctrl+q to avoid accidental quits
        unbind "Ctrl q"
    }
}
EOF

    log_success "Created ~/.config/zellij/config.kdl"
}

# ============================================================================
# 9. TMUX CONFIGURATION
# ============================================================================
setup_tmux() {
    log_info "Setting up tmux configuration..."

    cat > "$HOME/.tmux.conf" << 'EOF'
# Start windows and panes at 1, not 0
set -g base-index 1
setw -g pane-base-index 1

# No escape delay
set -s escape-time 0

# Vi mode
setw -g mode-keys vi

# Mouse support
set -g mouse on

# True color support
set -g default-terminal "screen-256color"
set-option -ga terminal-overrides ",xterm-256color:Tc"

# Pane navigation with Ctrl+Arrow
bind-key -n C-Left select-pane -L
bind-key -n C-Right select-pane -R
bind-key -n C-Up select-pane -U
bind-key -n C-Down select-pane -D
EOF

    log_success "Created ~/.tmux.conf"
}

# ============================================================================
# 10. CHANGE DEFAULT SHELL
# ============================================================================
change_default_shell() {
    log_info "Checking default shell..."

    if [[ "$SHELL" == *"zsh"* ]]; then
        log_success "zsh is already the default shell"
        return 0
    fi

    local zsh_path=$(which zsh)
    if [[ -z "$zsh_path" ]]; then
        log_error "zsh not found in PATH"
        return 1
    fi

    log_info "Changing default shell to zsh..."
    chsh -s "$zsh_path"

    log_success "Default shell changed to zsh"
    log_warn "Log out and back in for the change to take effect"
}

# ============================================================================
# MAIN
# ============================================================================
main() {
    echo ""
    echo "=============================================="
    echo "  Ubuntu Setup Script"
    echo "  Porting Nix config to native Ubuntu"
    echo "=============================================="
    echo ""

    install_apt_packages
    echo ""

    install_rust_tools
    echo ""

    install_scmpuff
    echo ""

    install_pure_prompt
    echo ""

    setup_zsh_config
    echo ""

    setup_neovim
    echo ""

    setup_git
    echo ""

    setup_zellij
    echo ""

    setup_tmux
    echo ""

    change_default_shell
    echo ""

    echo "=============================================="
    echo -e "${GREEN}  Setup complete!${NC}"
    echo "=============================================="
    echo ""
    echo "Next steps:"
    echo "  1. Log out and back in (or run 'zsh') to use zsh"
    echo "  2. Run 'nvim' to trigger LazyVim plugin installation"
    echo "  3. Optionally install a Nerd Font for icons in terminal"
    echo ""
}

main "$@"
