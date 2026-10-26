# AGENTS.md

Hades is a [Pearl](https://github.com/pearl-core/pearl) package for Arch Linux, not a standalone app. There is no build, test, lint, or CI pipeline; behavior lives in package lists, shell configs, and Pearl hooks.

## Layout and entrypoints

- `pearl-config/hooks.sh` — install/update logic. `post_update` calls `post_install`, so both must stay idempotent.
- `packages` — installed unconditionally. `packages-optional` — prompt-gated productivity tools. `packages-omarchy` — prompt-gated Omarchy extras.
- `configs/aliases` — shared aliases. Pearl sources `config.sh` for Bash and Zsh; Fish only sources `config.fish`, so it sources `configs/aliases` separately.
- Put shared Bash/Zsh startup logic in `config.sh`; shell-specific logic goes in `config.bash`/`config.zsh`. Fish never reads `config.sh`.
- `configs/omarchy/pacman.conf` — standalone pacman config used only by `pacboy`; it must keep `[core]` and `[extra]` as well as `[omarchy]`.
- `configs/herdr-config.toml` — reference only; the hook does not install it.
- `pearl-config/config.el` and `config.vim` are empty placeholders. `pearl-config/package.conf` is entirely commented out (no metadata is published).
- `README.md` is the user-facing contract; update it when packages, aliases, prompts, or Omarchy behavior change.

## Package-list rules

- One package per line; comments only as whole lines starting with `#`.
- Hooks parse lists as `grep -vE '^[[:space:]]*#' FILE | xargs`. Trailing/inline comments become package names, so never add them.
- Add core tools to `packages`, general optional tools to `packages-optional`, and packages from the Omarchy repo to `packages-omarchy`.
- Omarchy extras are installed only when the optional-products prompt is accepted. `_omarchy` then runs `omarchy-nvim-setup`.
- `herdr` is installed with `mise use -g herdr`; Hermes with its upstream installer. They are not package-list entries.
- `[omarchy]` deliberately uses `SigLevel = Never` (unsigned binary repo). Do not "fix" it without verifying the repo's signing setup.
- `pacboy` = `pacman --config "$PEARL_PKGDIR/configs/omarchy/pacman.conf"`. Since `sudo` does not expand aliases, privileged installs need the explicit config (`sudo pacman --config ... -S ...`).

## Hook constraints

- Never run `post_install` (or `pearl install`/`pearl update`) to test: it calls `sudo pacman -Syu`, prompts interactively, and mutates the system.
- Preserve install order: keyring refresh -> full upgrade -> core packages -> herdr -> Hermes prompt -> optional tools + Omarchy extras.
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
grep -vE '^[[:space:]]*#' packages packages-optional packages-omarchy
```

License: GPL-2.0 (declared in `README.md`; no `LICENSE` file yet).
