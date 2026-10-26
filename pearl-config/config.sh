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
[ -e /usr/bin/eza ] && alias ls="eza"
[ -e /usr/bin/z ] && alias cd="z"
# vim: ft=sh
