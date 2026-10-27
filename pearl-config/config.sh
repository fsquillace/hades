# Remove this file if bash/zsh configurations are not needed
#
# The following variables can be used:
# - *PEARL_HOME*        - Pearl location
# - *PEARL_PKGNAME*     - Pearl package name
# - *PEARL_PKGREPONAME* - Pearl package repository name
# - *PEARL_PKGDIR*      - Pearl package location
# - *PEARL_PKGVARDIR*   - Pearl package var location

add_to_path $HOME/.local/bin

source "$PEARL_PKGDIR/configs/aliases"
[ -e /usr/bin/eza ] && alias ls="eza --icons=auto --group-directories-first --color=auto"
[ -e /usr/bin/zoxide ] && alias cd="z"


# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
function y() {
	local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
	command rm -f -- "$tmp"
}

# vim: ft=sh
