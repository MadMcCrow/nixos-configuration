#!/usr/bin/env sh
HOST=$1
ATTR=$2
nix eval -v -L .#nixosConfigurations.$HOST.config.$ATTR --json --extra-experimental-features nix-command --extra-experimental-features flakes