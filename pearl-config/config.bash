# Remove this file if bash configurations are not needed
#
# The following variables can be used:
# - *PEARL_HOME*        - Pearl location
# - *PEARL_PKGNAME*     - Pearl package name
# - *PEARL_PKGREPONAME* - Pearl package repository name
# - *PEARL_PKGDIR*      - Pearl package location
# - *PEARL_PKGVARDIR*   - Pearl package var location

# https://wiki.archlinux.org/index.php/Fzf
if [[ -e /usr/bin/fzf ]]
then
    source /usr/share/fzf/key-bindings.bash
    source /usr/share/fzf/completion.bash
fi

eval "$(mise activate bash)"
[[ -e /usr/bin/starship ]] && eval "$(starship init bash)"
[[ -e /usr/bin/zoxide ]] && eval "$(zoxide init bash)"

source /usr/share/aichat/integration.bash

# vim: ft=sh
