# Lyceum: Declarative macOS Configuration

A minimal, declarative macOS environment using Nix, nix-darwin, and home-manager.

## Phase 1.1 Implementation ✓

This repository implements Phase 1.1 from the clean install specification: creating the new Nix repository structure before the system wipe.

### Validation Status ✓

All Nix files have been validated for correct syntax:
- ✓ `flake.nix` - Valid syntax
- ✓ `darwin/default.nix` - Valid syntax  
- ✓ `home/default.nix` - Valid syntax

### What's Included

- **Nix Flake** configuration with all required inputs
- **Darwin** system-level configuration 
- **Home Manager** user-level configuration
- **Placeholder** directories for dotfiles and secrets
- **SOPS** integration for secret management

### Pre-Wipe Checklist

Before proceeding with the system wipe:

1. [ ] Generate your age key: `age-keygen -o ~/.config/sops/age/keys.txt`
2. [ ] Update `.sops.yaml` with your age public key
3. [ ] Add your actual dotfiles to `dotfiles/nvim/`
4. [ ] Create encrypted secrets in `secrets/` directory
5. [ ] Update email in `home/default.nix`
6. [ ] Commit and push this repository to Git
7. [ ] Backup your age private key separately
8. [ ] Create Time Machine backup
9. [ ] Backup SSH keys separately

### Bootstrap Process (After Clean Install)

1. Restore age key to `~/.config/sops/age/keys.txt`
2. Install Nix:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```
3. Log in to Mac App Store
4. Clone this repository to `~/.config/nix`
5. Run `darwin-rebuild switch --flake .`
6. Log out and log back in

### Daily Usage

- **Rebuild**: `darwin-rebuild switch --flake ~/.config/nix`
- **Update**: `nix flake update && rebuild`
- **Dev tools**: `nix develop`
- **Run tools**: `nix run nixpkgs#<tool>`
