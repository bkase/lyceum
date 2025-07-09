Excellent. This final critique addresses the most subtle but important points, refining the specification into a truly elegant and robust plan. The shift to declarative environment variable injection is a significant improvement, and the other clarifications enhance the overall quality.

I have integrated all of these final changes. Here is the complete, definitive specification.

***

## Software Development Specification: Declarative macOS Environment v2.0

**Document Version:** 1.6 (Final)
**Date:** 2024-10-27
**Author:** Software Architect
**Project:** "Run-Heavy" Declarative macOS Configuration

### 1.0 Overview

This document outlines the specification for a new, declarative macOS environment. The primary architectural goal is to migrate from the existing, heavily customized `bkase-life` Nix configuration to a new paradigm: a **"minimal-install, maximal-`nix run`"** setup.

The new architecture will drastically simplify the core declarative base by leveraging `nix-darwin` for system services, `home-manager` for a unified user environment, and a clear, secure strategy for managing all graphical applications, dotfiles, and secrets, including environment variables.

### 2.0 Goals and Objectives

*   **Drastically Reduce Rebuild Times:** By minimizing the set of installed packages, `darwin-rebuild` operations will be significantly faster.
*   **Decouple Application Configuration:** Manage the entire LazyVim Neovim configuration within its own directory. Nix's role is simply to symlink this directory into place.
*   **Maintain a Clean Global `$PATH`:** The `$PATH` will only contain a handful of essential, always-on utilities.
*   **Full Declarative Application Management:** All GUI applications will be managed declaratively and centrally within the user's Home Manager configuration.
*   **Secure Secret Management:** All sensitive information, including file-based credentials and API keys for environment variables, will be encrypted and managed safely within the Git repository using `sops-nix`.
*   **Declarative and Secure Environment Variable Management:** Manage API keys and other secret environment variables declaratively and in a shell-agnostic way, without leaking them into the shell's history or Git repository.
*   **Enhance Reproducibility and Predictability:** Utilize Nix flakes and a `flake.lock` file for all core dependencies. On-demand tools will be explicitly referenced from the flake's locked inputs.
*   **Streamline Language Toolchain Management:** Offload language runtime management to `mise`, allowing for flexible, project-specific versioning.
*   **Simplify Onboarding:** The bootstrap process for a new machine will be unambiguous, robust, and include all necessary steps for a fully hydrated development environment.

### 3.0 Architectural Design

#### 3.1 Core Principles

1.  **Install-Light, Run-Heavy:** The system's declarative base should be as small as possible. CLI tools are "run" when needed, not installed globally.
2.  **Application-Owned Configuration:** Applications own their configuration files. The Nix setup's role is to manage this configuration declaratively.
3.  **Declarative First:** All state (packages, settings, dotfiles, services, GUI apps, secrets) must be managed declaratively.
4.  **Configuration vs. Secrets:** Normal configuration is stored in plaintext in Git. Sensitive secrets are encrypted before being committed.

#### 3.2 Technology Stack

*   **Nix:** Package manager and build system, with Flakes enabled.
*   **nix-darwin:** Manages macOS system-level configuration.
*   **Home Manager:** Manages the entire user-level configuration.
*   **sops-nix:** For declarative management of encrypted secrets, including files and environment variables.
*   **Homebrew:** Used by Nix to install GUI applications via its Cask system.
*   **mas-cli:** A command-line interface for the Mac App Store, managed via Home Manager.
*   **mise:** A polyglot version manager for language toolchains.

#### 3.3 Target Repository Structure

The repository will be restructured to reflect a clear separation of concerns, including a dedicated place for encrypted secrets.

```
~/.config/nix/
├── flake.nix                 # Top-level entry point.
├── flake.lock                # Pinned revisions of all flake inputs.
├── darwin/                   # System-level (nix-darwin) modules.
│   └── default.nix           # Host settings, services.
├── home/                     # User-level (home-manager) modules.
│   └── default.nix           # User shell, all GUI apps, packages, dotfiles, secrets.
├── dotfiles/                 # Application configurations (non-sensitive).
│   └── nvim/                 # Your entire LazyVim config directory.
└── secrets/                  # Encrypted secret files managed by sops.
    ├── gh/
    │   └── hosts.yml
    └── env.sops              # Encrypted .env file for API keys.
```

#### 3.4 Component Specification

##### 3.4.1 `flake.nix` (Top-Level)
*   **Purpose:** The single source of truth for dependencies and system assembly.
*   **Inputs:** Declares `nixpkgs`, `nix-darwin`, `home-manager`, and `sops-nix`.
*   **Outputs:** Defines the `darwinConfigurations."macbook"` and a `devShells.default` for on-demand tools.
    ```nix
    # flake.nix (snippet)
    outputs = { self, nixpkgs, sops-nix, ... } @ inputs: {
      # ... darwinConfigurations ...

      devShells.default = nixpkgs.legacyPackages.aarch64-darwin.mkShell {
         buildInputs = with nixpkgs.legacyPackages.aarch64-darwin; [
           jq ripgrep fd # Add other common one-off tools here
         ];
      };
    };
    ```

##### 3.4.2 `darwin/default.nix` (System Level)
*   **Purpose:** To manage machine-wide settings and services. This file remains minimal.
*   **Responsibilities:**
    *   Set `users.primaryUser`.
    *   Enable Nix Flakes and the daemon.
    *   Manage system services like **Tailscale** and **XCode**.
    *   Enable Homebrew for use by Home Manager.

##### 3.4.3 `home/default.nix` (User Level)
*   **Purpose:** To be the central hub for all user-specific configuration, including applications, dotfiles, and secrets.
*   **Responsibilities:**
    *   Enable and configure `sops` for secret decryption.
    *   Manage secret environment variables declaratively via `home.sessionVariables` and `sops-nix`.
    *   Define all user GUI applications in one place, using `home.casks` and `home.mas`.
    ```nix
    # home/default.nix
    { config, pkgs, ... }: {
      sops.enable = true;

      # Declarative environment variable management from secrets
      home.sessionVariables = {
        # The 'sops' attribute tells Home Manager to get the value
        # from the specified sops secret.
        # This assumes your env.sops file contains key-value pairs like:
        # OPENAI_API_KEY=...
        OPENAI_API_KEY = config.sops.secrets.api-keys.value;
        GITHUB_TOKEN = config.sops.secrets.api-keys.value;
      };
      
      # Define the source files for sops to use
      sops.secrets."api-keys" = { source = ../secrets/env.sops; format = "dotenv"; };
      sops.secrets."gh-hosts" = {
        source = ../secrets/gh/hosts.yml;
        target = "${config.home.homeDirectory}/.config/gh/hosts.yml";
      };
      
      # Mac App Store apps & Homebrew Casks
      home.mas.enable = true;
      home.mas.apps = [ ... ];
      home.casks = [ ... ];

      # Link non-sensitive dotfiles
      home.file.".config/nvim".source = ../dotfiles/nvim;
      # ...
    }
    ```

### 5.0 Day-to-Day Workflow

*   **System Updates:** Run `nix flake update` followed by `darwin-rebuild switch --flake .`.
*   **On-Demand Tools:** For common utilities, run `nix develop` in the configuration's root directory. This provides a shell with tools like `jq` and `ripgrep`, all pinned to the versions in `flake.lock`.
*   **Project Tooling:** Use per-project `.mise.toml` files and run `mise install`.
*   **Managing Live Dotfiles:** For configurations like Neovim, be aware that `home.file` creates a symlink from `~/.config/nvim` to the source `dotfiles/nvim/` directory in your Git repository. Therefore, any changes made by the application (e.g., your plugin manager updating `lazy-lock.json`) directly modify the files in your repo. To keep your configuration's state synchronized, you must periodically `git commit` these changes. This workflow intentionally treats your Git repository as the single source of truth for your live configuration.
*   **Adding a GUI App:** Edit `home/default.nix` and add the application to either `home.mas.apps` or `home.casks`, then rebuild.
*   **Managing Secrets:** Use the `sops` CLI to edit encrypted files (e.g., `sops secrets/env.sops`). The changes will be applied on the next `darwin-rebuild`.

### 6.0 Bootstrap Process (New Machine)

**0. Prerequisite:** If you have an existing Homebrew installation, uninstall it first to prevent conflicts with the declarative setup.

1.  **Set up Decryption Keys:** Ensure your SOPS decryption key (e.g., a GPG key or an `age` key) is available on the machine. For `age`, this typically means copying your private key to `~/.config/sops/age/keys.txt`.
2.  **Install Nix (Determinate Systems):** This installer is chosen for its streamlined, idempotent, and Flake-friendly setup.
    ```bash
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    ```
3.  **Log in to Mac App Store:** Manually log in to the App Store application once to authenticate `mas-cli`.
4.  **Clone Repository:** `git clone <your-repo-url> ~/.config/nix`.
5.  **Build and Activate:**
    ```bash
    cd ~/.config/nix
    # This single command builds the system and activates it.
    darwin-rebuild switch --flake .
    ```
    *Note: For debugging, you can separate these steps into `nix build ...` followed by `./result/sw/bin/darwin-rebuild switch ...`.*
6.  **Log out and log back in** to ensure the new shell and Home Manager environment are fully active.
7.  **Install Language Toolchains:** Once logged back in, run `mise install` in any relevant project directory to download the language runtimes managed by `mise`.

### 7.0 Appendix: Declarative Management Strategy

| Item Type                      | Management Method                         | Rationale                                                                        |
| ------------------------------ | ----------------------------------------- | -------------------------------------------------------------------------------- |
| **Secret Env Vars (API Keys)**   | `sops-nix` + `home.sessionVariables`      | Shell-agnostic, declarative injection of secrets into the user session. Secure and robust. |
| **Secret Files (gh config)**     | `sops-nix` (file target)                  | Decrypts an entire file to a specific path, readable only by the user.          |
| **User GUI Apps (MAS)**        | Home Manager `mas`                        | Centralized, declarative management of Mac App Store applications.               |
| **User GUI Apps (Cask)**       | Home Manager Cask (`home.casks`)          | Centralized, declarative management of non-MAS applications.                     |
| **System Services (XCode, etc.)**| `nix-darwin` (`programs.*`, `services.*`) | For system-wide daemons and tools that require root privileges or deep integration.|
| **Non-Secret Dotfiles**        | Home Manager (`home.file`)                | Simple, declarative symlinking of version-controlled configuration files.        |
| **Language Toolchains**        | `mise`                                    | Per-project or global version management without requiring a system rebuild.      |