#!/usr/bin/env sh
# nixfmt.sh 
#   A simple script to format your nix files
FILES=$1

# Format with nixfmt
printf "formatting with \033[0;34mnixfmt\033[0m...\n"
for FILE in $FILES
do
    nix-shell -p nixfmt-rfc-style --run "nixfmt  <$FILE" 1> /dev/null;
    RES=$?
    if [ $RES -ne 0 ]; then
        echo -e "\033[0;31m\0Error:\033[0m \033[0;34m$FILE\033[0m is not formatted, run\033[1;34m'nixfmt $FILE'\033[0m"
        printf "Format complete with errors"
        exit $RES
    fi
done
  printf "Format check: \033[0;32mSuccess!\033[0m"