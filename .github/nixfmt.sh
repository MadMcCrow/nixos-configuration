#!/usr/bin/env sh
# nixfmt.sh 
#   A simple script to format your nix files
# Format with nixfmt
printf "formatting with \033[0;34mnixfmt\033[0m...\n"
for file in $1; do
    nix-shell -p nixfmt-rfc-style --run "nixfmt  <$file" 1> /dev/null;
    ret=$?
    if [ $ret -ne 0 ]; then
        printf "\033[0;31m\0Error:\033[0m \033[0;34m%s\033[0m is not formatted, run\033[1;34m'nixfmt%s'\033[0m" "$file" "$file"
        printf "Format complete with errors"
        exit $ret
    fi
done
printf "Format check: \033[0;32mSuccess!\033[0m"