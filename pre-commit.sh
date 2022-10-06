#!/usr/bin/env sh
CHANGED_FILES="$(git diff --cached --name-only --diff-filter=ACM -- '*.nix')";
if \[ -n "$CHANGED_FILES" \]; then
    for FILE in $CHANGED_FILES
    do
        nix-shell -p nixfmt --run "nixfmt $FILE" 1> /dev/null;
        git add $FILE;
    done
    echo "Files updated by nixfmt :"
    echo "$CHANGED_FILES";
fi

