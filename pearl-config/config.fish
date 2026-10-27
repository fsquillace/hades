# Remove this file if a fish configurations are not needed
#
# The following variables can be used:
# - *PEARL_HOME*        - Pearl location
# - *PEARL_PKGNAME*     - Pearl package name
# - *PEARL_PKGREPONAME* - Pearl package repository name
# - *PEARL_PKGDIR*      - Pearl package location
# - *PEARL_PKGVARDIR*   - Pearl package var location

# https://wiki.archlinux.org/index.php/Fzf
function fish_user_key_bindings
    fzf_key_bindings
end

add_to_path $HOME/.local/bin

mise activate fish | source
[ -e /usr/bin/starship ]; and starship init fish | source
[ -e /usr/bin/zoxide ]; and zoxide init fish | source

source /usr/share/aichat/integration.fish

source $PEARL_PKGDIR/configs/aliases
[ -e /usr/bin/eza ]; and alias ls="eza --icons=auto --group-directories-first --color=auto"
[ -e /usr/bin/zoxide ]; and alias cd="z"


# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	command rm -f -- "$tmp"
end
# vim: ft=sh
