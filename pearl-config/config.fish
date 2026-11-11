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

# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
function y
	set tmp (mktemp -t "yazi-cwd.XXXXXX")
	command yazi $argv --cwd-file="$tmp"
	if read -z cwd < "$tmp"; and [ "$cwd" != "$PWD" ]; and test -d "$cwd"
		builtin cd -- "$cwd"
	end
	command rm -f -- "$tmp"
end

# https://superfile.dev/configure/superfile-config/
function spf
    set os $(uname -s)

    if test "$os" = "Linux"
        set spf_last_dir "$HOME/.local/state/superfile/lastdir"
    end

    if test "$os" = "Darwin"
        set spf_last_dir "$HOME/Library/Application Support/superfile/lastdir"
    end

    command spf $argv

    if test -f "$spf_last_dir"
        source "$spf_last_dir"
        rm -f -- "$spf_last_dir" >> /dev/null
    end
end

[ -e /usr/bin/nvim ]; and set -x EDITOR nvim
[ -e /usr/bin/nvim ]; and set -x VISUAL nvim


# https://wiki.archlinux.org/title/Install_Arch_Linux_on_WSL#Run_graphical_applications_with_WSLg
set -g GALLIUM_DRIVER d3d12
set -g LIBVA_DRIVER_NAME d3d12
# vim: ft=sh
