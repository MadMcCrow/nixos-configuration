#!/bin/env sh
# raw build a system.
# this is only intended for debugging purposes
if [ -z "$1" ]
  then
    echo "no config path provided, aborting"
    exit 1
fi
if [ -z "$2" ]
  then
    FLAKEPATH="path:$(pwd)"
else
    FLAKEPATH="$2"
fi
# make sure flakes and commands are enabled
FEATURES="--extra-experimental-features 'nix-command flakes'"
LOG="--log-format internal-json"
# run the build
nix "$FEATURES" "$LOG" build --impure --expr "(builtins.getFlake \"$FLAKEPATH\").lib.mkSystem $1"
