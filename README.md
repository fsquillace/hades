# Hades

**A minimal, AI-ready Arch Linux workstation — productive from day one.**

Hades is a [Pearl](https://github.com/pearl-core/pearl) package that turns a fresh Arch Linux install into a lightweight, terminal-first development environment with a complete AI toolchain already installed and wired together.

No desktop environment, no Electron apps, no manual setup checklist. Install one package, add your model credentials, and start working.

Hades also works as a minimal, ready-to-use platform inside **WSL** with an Arch Linux distro, so Windows users can get the same terminal-first agent setup without a full Linux desktop.

---

## Why Hades?

Setting up a useful AI-assisted development environment usually means installing a dozen tools, remembering each one's configuration format, and gluing them together by hand. Hades does that once, reproducibly:

- **Lightweight** — terminal-native tools only; herdr is a single Rust binary.
- **Minimal** — a small, opinionated package set instead of a full distro.
- **AI-first** — the four tools below share one workspace and one shell workflow.
- **Arch-native** — packages come from the official repositories; the system stays simple to update.
- **Omarchy extras, on demand** — install packages from the Omarchy repository with `pacboy` without adopting Omarchy itself.
- **WSL-ready** — the same minimal platform runs inside an Arch Linux WSL distro on Windows, with graphical support packages installed automatically.
- **Reproducible** — everything is declared in version-controlled package lists and Pearl hooks.

---

## The stack

| Tool | Role | Links |
| --- | --- | --- |
| **herdr** | Central agent workspace and runtime. Keeps agent terminals alive, tracks working/blocked/idle state, and hosts every agent pane in one place. | [herdr.dev](https://herdr.dev) · [GitHub](https://github.com/herdrdev/herdr) |
| **opencode** | Primary coding agent. Reads, writes, and navigates your codebase directly from the terminal. | [opencode.ai](https://opencode.ai) · [GitHub](https://github.com/sst/opencode) |
| **Hermes** | Planning, coordination, and automation. Long-running agent for schedules, subagents, and multi-step workflows. | [hermes-agent.nousresearch.com](https://hermes-agent.nousresearch.com) · [GitHub](https://github.com/NousResearch/hermes-agent) |
| **aichat** | Natural language to shell commands. Ask for a command in plain English and run it without leaving the prompt. | [GitHub](https://github.com/sigoden/aichat) |

### How they fit together

```
                 ┌──────────────────────────────┐
                 │            herdr             │
                 │  workspace · panes · agents  │
                 └───────────┬──────────────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                  │
     ┌────▼─────┐      ┌─────▼─────┐      ┌─────▼─────┐
     │ opencode │      │  Hermes   │      │  aichat   │
     │  coding  │      │ planning  │      │   shell   │
     └──────────┘      └───────────┘      └───────────┘
```

herdr is the home base. You run opencode for hands-on coding, Hermes for planning and unattended work, and aichat whenever you just need the right shell command.

**opencode is the default coding agent, not a lock-in.** You can install and use any of the agents listed in the [Omarchy AI manual](https://omarchy.org/manual/ai/) — Claude Code, Codex, Google Antigravity, Amp, Crush, Cursor CLI, Qwen Code, and many more — and use them in place of, or alongside, opencode.

---

## What gets installed

### Core

Installed automatically from [`packages/main`](packages/main):

- **Base tools** — `base-devel`, `git`, `mise`, `yay`
- **AI tools** — `aichat`, `opencode`, `herdr`, `herdr-app`
- **Hermes** — offered as a prompt during installation; distributed through its own installer into `~/.hermes`.

### Fonts

Installed automatically from [`packages/fonts`](packages/fonts): basic font families (`liberation`, `dejavu`, `noto`, `cantarell`, `ubuntu`) plus `fontconfig`, with the font cache refreshed after install.

### WSL only

Installed automatically from [`packages/wsl`](packages/wsl) when WSL is detected: `mesa`, `vulkan-dzn`, and `vulkan-icd-loader`, which enable graphical applications through WSLg.

### Optional productivity tools

Installed from [`packages/optional`](packages/optional) when the installation prompt is accepted (default: no):

- **Shell and navigation:** `fzf`, `zoxide`, `starship`, `eza`, `fd`, `ripgrep`
- **Editing and Git:** `neovim`, `lazygit`, `github-cli`
- **Utilities:** `btop`, `fastfetch`, `jq`, `yazi`, `7zip`, `ffmpeg`, `imagemagick`, `poppler`, `resvg`, and more
- **[Omarchy Neovim](https://omarchy.org/manual/neovim/):** a LazyVim-based setup, configured via `omarchy-nvim-setup`

All packages are installed through a dedicated pacman configuration ([`configs/pacman.conf`](configs/pacman.conf)) that also contains the Omarchy repository — see [Omarchy packages and AI agents](#omarchy-packages-and-ai-agents).

---

## Requirements

- **Arch Linux** (the package uses `pacman` directly).
- **Or an Arch Linux WSL distro** — Hades works as a minimal ready platform inside WSL on Windows. Install the Arch Linux distro, open its shell, and follow the same steps below.
- **sudo** access. The install hook updates the system, installs packages, and refreshes the keyring.
- **Network access** to the Arch mirrors and the herdr download source.
- Pearl's own dependencies: `python`, `bash >= 4.1`, `git`.

> **Note:** `post_install` runs a full `pacman -Syu` before installing anything. Review `pearl-config/hooks.sh` if you prefer to control upgrades yourself.

---

## Installation

### 1. Install Pearl

```bash
sudo pacman -Sy python-pipx
pipx install pearl
pearl init
```

`pearl init` will make Pearl available to bash, zsh and fish shells.

- Open a new shell to have all Pearl variables initialized correctly

### 2. Install Hades

- Add new Pearl repo index to your Pearl configuration at `~/.config/pearl/pearl.conf`:

```bash
PEARL_REPOS += ("https://github.com/fsquillace/pearl-repo.git", )
```

- Install `hades`

```bash
pearl install hades
```
- Open a new shell or simply run `pearl-source` to the existing one to have all functions and variables initialized.

The Pearl hook will, in order: refresh the Arch keyring → run a full system upgrade → install the core packages → install the WSL graphical packages (WSL only) → install the fonts and refresh the font cache → install the herdr configuration and keybindings and register the opencode integration → optionally set up Hermes (registering its herdr integration) → optionally install the productivity tools including Omarchy Neovim.

### 3. (Optional but highly recommended) Install a NerdFont

- In order to have the terminal (Windows Terminal for WSL, foot, Ghostty, Kitty, etc) of your choice being able to draw custom glyphs from Hades programs (yazi, lazygit, starship, etc) it is highly recommended to install any of the [NerdFont](https://www.nerdfonts.com/) of your choice. Hades cannot install fonts into your terminal application for you.

### 4. Connect your models

#### 4.1 Explore from the [Bench LM Leaderboard](https://benchlm.ai) the LLMs to use

Some advices: 
  - OpenCode Plan -> Use a model from the leaderboard with high [Reasoning score](https://benchlm.ai/?sort=cat_reasoning)
  - OpenCode Build -> Use a model from the leaderboard with high [Coding score](https://benchlm.ai/?sort=cat_coding)
  - Hermes -> Use a model from the leaderboard with high [Agentic score](https://benchlm.ai/?sort=cat_agentic)
  - AIChat -> Use a model from the leaderboard with high [Coding/Reasoning score](https://benchlm.ai)

Alternative leaderboards: [Artificial Analysis](https://artificialanalysis.ai/leaderboards/models), [WhatLLM.org](https://whatllm.org/explore).

#### 4.2 Setup your models

Each tool authenticates independently. Configure the ones you plan to use:

```bash
opencode auth login   # OpenCode providers
hermes setup          # Hermes provider and tools
aichat                # Setup procedure when running for first time
```

For aichat, add at least one provider to `~/.config/aichat/config.yaml` — see the [Configuration Guide](https://github.com/sigoden/aichat/wiki/Configuration-Guide).

---

## Quick start

```bash
# Start the agent workspace
herdr

# Or its GUI companion (already routed through XWayland when needed)
herdr-app

# Run the coding agent inside a pane
opencode

# Plan, coordinate, or schedule work
hermes

# Generate a command from plain English and prompt for execution, revise and describe
aiexec show disk usage grouped by folder

# Aichat shell integration: Ask for a shell command in plain language and press Alt-e, it will translate into a real command directly from shell
find the largest files in this directory <Alt-e>

# Install packages in Omarchy repository
sudo pacboy -Sy claude-code
```

To learn more about the aichat shell integration [here](https://github.com/sigoden/aichat/wiki/Command-Line-Guide?utm_source=chatgpt.com#shell-integration).

### herdr and herdr-app

Hades installs and activates both `herdr` (the terminal workspace) and `herdr-app` (its GUI companion). The hook does all the configuration for you:

- Copies the reference herdr configuration ([`configs/herdr-config.toml`](configs/herdr-config.toml)) to `~/.config/herdr/config.toml` — tmux-style `ctrl+space` prefix, Gruvbox theme, system toast notifications.
- Copies custom predefined keybindings `~/.config/herdr-app/keys.json` — Allows to have similar keybinding experience as the herdr TUI.
- Registers the opencode integration so agents run inside the workspace (and the hermes integration when Hermes is installed).

Any pre-existing configuration file is backed up first, so re-running `pearl update` never silently discards your changes.

From there, `herdr` opens the workspace, `ctrl+space` is your tmux-style prefix, and agents keep running when you detach or lose an SSH connection. On WSL, launch the graphical version with `herdr-app` — the alias routes it through XWayland to work around a WSLg Wayland bug.

---

## Shell integration

Hades configures Bash, Zsh, and Fish on first shell start:

- Activates `mise` so globally installed tools such as `herdr` are on `PATH`.
- Initializes `starship`, `zoxide`, and `fzf` when those packages are present.
- Loads the official aichat shell integration.
- Adds `~/.local/bin` to `PATH`.
- Sources the shared aliases in [`configs/aliases`](configs/aliases).

Included aliases:

```bash
aiexec="aichat -e"      # natural language → executable command
pacman="pacman --color auto"
pacboy="pacman --config $PEARL_PKGDIR/configs/pacman.conf"
herdr-app="env -u WAYLAND_DISPLAY herdr-app"   # WSLg Wayland workaround
ls="eza"                # when eza is installed
cd="z"                  # when zoxide is installed
```

`pacboy` is the enhanced `pacman` entry point that also sees the Omarchy repository. See [Omarchy packages and AI agents](#omarchy-packages-and-ai-agents) for usage.

---

## Omarchy packages and AI agents

Hades borrows the useful, agentic parts of [Omarchy](https://omarchy.org) without the desktop. You get its package repository and its agent ecosystem while keeping a minimal, terminal-first system.

### Install Omarchy packages with `pacboy`

Hades ships a dedicated pacman configuration in [`configs/pacman.conf`](configs/pacman.conf) and exposes it through the `pacboy` alias:

```bash
pacboy -Ss <query>      # search Arch + Omarchy packages
pacboy -S <package>     # install a package from the Omarchy repository
```

`pacboy` is an enhanced `pacman`: it includes the official `core` and `extra` repositories plus the `omarchy` repository, so any package published in the [omarchy-pkgs PKGBUILDs](https://github.com/omacom/omarchy-pkgs/tree/master/pkgbuilds) can be installed from the same command line.

### Use any Omarchy coding agent

opencode is only the default. You can install and use any of the coding agents catalogued in the [Omarchy AI manual](https://omarchy.org/manual/ai/) as a replacement — Claude Code (`claude`), OpenAI Codex (`codex`), Google Antigravity (`agy`), Amp, Command Code, GitHub Copilot CLI, Crush, Cursor CLI, Devin, DeepSeek Harness, Freebuff, Grok, Hermes, Kilo, Kimi, Kiro CLI, MiniMax Code, Muse Code, Oh My Pi, Ori, Pi, and Qwen Code. Install your preferred agent with its upstream installer, `mise`, or `pacboy` when an Omarchy package exists, authenticate it, and run it inside a herdr pane just like opencode.

Hades preconfigures the herdr integrations for opencode and Hermes, but the rest of the stack is agent-agnostic: your shell, aliases, and workspace do not change when you switch agents.

### Not an Omarchy replacement

Hades is **not** meant to replace Omarchy. Omarchy is a full, opinionated desktop built around Hyprland, themes, and visual polish. Hades deliberately leaves that out. It is for anyone who wants the agentic side of Omarchy — its package repository, its coding agents, and its Nvim setup — without the aesthetics and bloat of a full desktop environment.

---

## Design principles

1. **Stay close to Arch.** Official repositories first; avoid unnecessary AUR surface area.
2. **Stay terminal-first.** Fast startup, low memory, no graphical stack required.
3. **Own your configuration.** Everything lives in plain files that you can read, diff, and version.
4. **One install, working defaults.** Sensible settings now; full freedom to override later.

---

## License

Hades is free software released under the **GNU General Public License, version 2 (GPL-2.0)**.

You can redistribute it and/or modify it under the terms of the GPL v2 as published by the Free Software Foundation. See the [full GPL-2.0 license text](https://www.gnu.org/licenses/old-licenses/gpl-2.0.html) for details. Hades is distributed in the hope that it will be useful, but **without any warranty**, including the implied warranties of merchantability or fitness for a particular purpose.
