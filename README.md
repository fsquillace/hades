# Hades

**A minimal, AI-ready Arch Linux workstation — productive from day one.**

Hades is a [Pearl](https://github.com/pearl-core/pearl) package that turns a fresh Arch Linux install into a lightweight, terminal-first development environment with a complete AI toolchain already installed and wired together.

No desktop environment, no Electron apps, no manual setup checklist. Install one package, add your model credentials, and start working.

---

## Why Hades?

Setting up a useful AI-assisted development environment usually means installing a dozen tools, remembering each one's configuration format, and gluing them together by hand. Hades does that once, reproducibly:

- **Lightweight** — terminal-native tools only; herdr is a single Rust binary.
- **Minimal** — a small, opinionated package set instead of a full distro.
- **AI-first** — the four tools below share one workspace and one shell workflow.
- **Arch-native** — packages come from the official repositories; the system stays simple to update.
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

---

## What gets installed

### Core

Installed automatically by the Pearl hook:

- `base-devel` — required for building AUR packages
- `git`
- `mise` — runtime and tool version manager
- `aichat`
- `opencode`
- `herdr` — installed globally through `mise`
- `hermes` - distributed through its own installer into `~/.hermes`
- The `opencode` and `hermes` integration for herdr

### Optional productivity tools

Offered as a prompt during installation (default: no):

- **Shell and navigation:** `fzf`, `zoxide`, `starship`, `exa`, `fd`, `ripgrep`
- **Editing and Git:** `neovim`, `lazygit`, `github-cli`
- **Utilities:** `btop`, `fastfetch`, `jq`, `curl`, `wget`, `tar`, `zip`, `unzip`, `less`, `man-db`, `openssh`

---

## Requirements

- **Arch Linux** (the package uses `pacman` directly).
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

### 2. Install Hades

- Add Hades to your Pearl configuration at `~/.config/pearl/pearl.conf`:

```bash
PEARL_PACKAGES['hades'] = {"url": "https://github.com/fsquillace/hades.git"}
```
- Install `hades`
```bash
pearl install hades
```

The hook will refresh the Arch keyring, upgrade the system, install the core packages, prompt for the optional productivity set, set up herdr and hermes.

### 4. Connect your models

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

# Run the coding agent inside a pane
opencode

# Plan, coordinate, or schedule work
hermes

# Generate a command from plain English and prompt for execution, revise and describe
aiexec show disk usage grouped by folder

# Aichat shell integration: Ask for a shell command in plain language and press Alt-e, it will translate into a real command directly from shell
find the largest files in this directory <Alt-e>
```

To learn more about the aichat shell integration [here](https://github.com/sigoden/aichat/wiki/Command-Line-Guide?utm_source=chatgpt.com#shell-integration).

### herdr basics

Hades ships a reference herdr configuration in [`configs/herdr-config.toml`](configs/herdr-config.toml):

- `ctrl+space` as the prefix key
- Gruvbox theme
- System toast notifications
- Onboarding skipped

Hades does not automate installation of this file (for now). If you want it, just copy it into place after installing:

```bash
mkdir -p "$HOME/.config/herdr"
cp configs/herdr-config.toml "$HOME/.config/herdr/config.toml"
```

From there, `herdr` opens the workspace, `ctrl+space` is your tmux-style prefix, and agents keep running when you detach or lose an SSH connection.

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
ls="eza"                # when eza is installed
cd="z"                  # when zoxide is installed
```

---

## Design principles

1. **Stay close to Arch.** Official repositories first; avoid unnecessary AUR surface area.
2. **Stay terminal-first.** Fast startup, low memory, no graphical stack required.
3. **Own your configuration.** Everything lives in plain files that you can read, diff, and version.
4. **One install, working defaults.** Sensible settings now; full freedom to override later.

---

## License

GPLv2
