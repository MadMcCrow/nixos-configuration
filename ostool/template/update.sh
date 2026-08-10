#!/usr/bin/env sh

# find the template and root folder
root=$(git rev-parse --show-toplevel)
tmpl_npins="$root/ostool/template/src/npins"

# migrate schema if npins format changed
npins -d "$tmpl_npins" upgrade

# find the tags and revisions
nixpkgs_rev=$(jq -r '.nodes.nixpkgs.locked.rev' "$root/flake.lock")
nonos_rev=$(git -C "$root" rev-parse HEAD)
nonos_branch=$(git -C "$root" rev-parse --abbrev-ref HEAD)

# update the pins
npins -d "$tmpl_npins" add github NixOS nixpkgs --branch nixos-unstable --at "$nixpkgs_rev"
npins -d "$tmpl_npins" add github MadMcCrow nonOS --branch "$nonos_branch" --at "$nonos_rev"