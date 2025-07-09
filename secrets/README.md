# Secrets Directory

This directory contains encrypted secrets managed by sops-nix.

## Structure:
- `env.sops` - Encrypted environment variables (API keys, tokens)
- `gh/hosts.yml` - Encrypted GitHub CLI configuration

## Usage:
1. Create your age key: `age-keygen -o ~/.config/sops/age/keys.txt`
2. Create `.sops.yaml` in the repository root with your age public key
3. Encrypt files: `sops env.sops`

Never commit unencrypted secrets to this repository!