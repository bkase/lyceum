# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with anything on my computer

## Important tips

- DONT rely on pre-installed tooling. When a command/tool is missing, prefer using devenv for development environments, and fall back to `cx` for one-off commands.

## Development Environments

**Prefer devenv first** for any development work:

When `devenv.nix` doesn't exist and a command/tool is missing, create ad-hoc environment:

```bash
devenv -O languages.rust.enable:bool true -O packages:pkgs "mypackage mypackage2" shell -- cli args
```

When the setup becomes complex, create `devenv.nix` and run commands within:

```bash
devenv shell -- cli args
```

See https://devenv.sh/ad-hoc-developer-environments/

**Fall back to cx** for simple one-off commands:

```bash
cx wget
cx rg
```
