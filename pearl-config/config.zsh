# Remove this file if zsh configurations not needed
#
# The following variables can be used:
# - *PEARL_HOME*        - Pearl location
# - *PEARL_PKGNAME*     - Pearl package name
# - *PEARL_PKGREPONAME* - Pearl package repository name
# - *PEARL_PKGDIR*      - Pearl package location
# - *PEARL_PKGVARDIR*   - Pearl package var location


if [[ -e /usr/bin/fzf ]]
then
    # https://wiki.archlinux.org/index.php/Fzf
    source /usr/share/fzf/key-bindings.zsh
    source /usr/share/fzf/completion.zsh
fi

eval "$(mise activate zsh)"
[[ -e /usr/bin/starship ]] && eval "$(starship init zsh)"
[[ -e /usr/bin/zoxide ]] && eval "$(zoxide init zsh)"

source /usr/share/aichat/integration.zsh

# vim: ft=sh
