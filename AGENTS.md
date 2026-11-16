# AGENTS.md

Hades is a [Pearl](https://github.com/pearl-core/pearl) package for Arch Linux, not a standalone app. There is no build, test, lint, or CI pipeline; behavior lives in package lists, shell configs, and Pearl hooks.

## Layout and entrypoints

- `pearl-config/hooks.sh` — install/update logic. `post_update` calls `post_install`, so both must stay idempotent.
- `packages/main` — installed unconditionally (base tools: `base-devel`, `git`, `mise`, `yay`; AI tools: `aichat`, `opencode`, `herdr`, `herdr-app`).
- `packages/optional` — prompt-gated productivity tools, including `omarchy-nvim`.
- `packages/wsl` — installed only when WSL is detected (`grep` on `/proc/version` in `_wsl`).
- `packages/fonts` — installed unconditionally, followed by `fc-cache -f`.
- `configs/aliases` — shared aliases. Pearl sources `config.sh` for Bash and Zsh; Fish only sources `config.fish`, so it sources `configs/aliases` separately.
- `pearl-config/config.bash`, `config.zsh`, and `config.fish` each source `$PEARL_PKGVARDIR/shell-doctor/scripts/integration.<shell>` — the Shell Doctor failure prompt hook. The repo itself is not in this package; it is cloned from git by the `_shell_doctor` hook.
- Put shared Bash/Zsh startup logic in `config.sh`; shell-specific logic goes in `config.bash`/`config.zsh`. Fish never reads `config.sh`.
- `configs/pacman.conf` — standalone pacman config used by the `_pacman` wrapper for every hook install (core, optional, WSL, fonts); it must keep `[core]` and `[extra]` as well as `[omarchy]`. `pacboy` points to the same file.
- `configs/herdr-app-keys.json` — herdr-app keybindings. The `_herdr` hook copies both it and the herdr config into place.
- `pearl-config/config.el` and `config.vim` are empty placeholders. `pearl-config/package.conf` is entirely commented out (no metadata is published).
- `README.md` is the user-facing contract; update it when packages, aliases, prompts, or Omarchy behavior change.

## Package-list rules

- One package per line; comments only as whole lines starting with `#`.
- Hooks parse lists as `grep -vE '^[[:space:]]*#' FILE | xargs`. Trailing/inline comments become package names, so never add them.
- Add base/AI tools to `packages/main`, general productivity tools to `packages/optional` (Omarchy packages like `omarchy-nvim` live here too), WSL-only packages to `packages/wsl`, and fonts to `packages/fonts`.
- `omarchy-nvim` is part of the optional set; when the optional-products prompt is accepted, `_omarchy_nvim` runs `omarchy-nvim-setup` after the packages install.
- All hook installs go through `_pacman` (`sudo pacman --noconfirm --config "$PEARL_PKGDIR/configs/pacman.conf"`), not plain `pacman`. Since `sudo` does not expand aliases, privileged installs cannot use the `pacboy` alias — reuse `_pacman` or write the explicit config.
- `herdr`, `herdr-app`, and `opencode` are plain pacman packages from `packages/main`. Hermes and Shell Doctor are the exceptions: Hermes is installed with its upstream installer into `~/.hermes`, and Shell Doctor is cloned from git into `$PEARL_PKGVARDIR/shell-doctor` (with `bin/doctor` linked to PATH); neither is a package-list entry.
- `[omarchy]` deliberately uses `SigLevel = Never` (unsigned binary repo). Do not "fix" it without verifying the repo's signing setup.

## Hook constraints

- Never run `post_install` (or `pearl install`/`pearl update`) to test: it calls `sudo pacman -Syu`, prompts interactively, and mutates the system.
- Preserve install order: keyring refresh -> full upgrade -> main packages -> `_wsl` (detection + WSL packages) -> `_fonts` + `fc-cache` -> `_herdr` (configs + keybindings + opencode integration) -> `_shell_doctor` (git clone into `$PEARL_PKGVARDIR/shell-doctor`, `bin/doctor` linked to PATH) -> Hermes prompt (installer, then `herdr integration install hermes`) -> optional tools prompt (`_omarchy_nvim` afterwards).
- `_herdr` overwrites live config files (`~/.config/herdr/config.toml`, `~/.config/herdr-app/keys.json`); always keep the existing `backup` calls before the `cp`, and modify the package-side copies (`configs/herdr-config.toml`, `configs/herdr-app-keys.json`), not the user's files.
- The `herdr-app` alias excludes `WAYLAND_DISPLAY` to route WSLg through XWayland (known WSLg bug); keep it when touching aliases.
- Use `$PEARL_PKGDIR`; do not hardcode repo paths. Keep the existing `function name()` shell style.
- Hooks assume Arch Linux (or an Arch WSL distro), `pacman`, and `sudo`.

## Verification

No automated checks exist. Run the cheap ones before committing:

```bash
bash -n pearl-config/hooks.sh
bash -n pearl-config/config.sh
bash -n pearl-config/config.bash
zsh -n pearl-config/config.zsh              # when zsh is installed
fish --no-execute pearl-config/config.fish  # when fish is installed
git diff --check
grep -vE '^[[:space:]]*#' packages/main packages/optional packages/wsl packages/fonts
```

License: GPL-2.0 (declared in `README.md`; no `LICENSE` file yet).
