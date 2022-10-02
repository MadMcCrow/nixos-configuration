#!/usr/bin/env sh
CHANGED_FILES="$(git diff --cached --name-only --diff-filter=ACM -- '*.nix')";

if \[ -n "$CHANGED_FILES" \]; then
    for FILE in $CHANGED_FILES :
    do
        nix-shell -p nixfmt --run "nixfmt $FILE";
        git add $FILE;
    done
    echo "Files updated by nixfmt :\n$CHANGED_FILES";
fi

