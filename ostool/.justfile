mod init
mod install
mod update

git_root:="$(git rev-parse --show-toplevel)"
tmpl_npins:="./template/src/npins"

update_template : _upgrade _update

[script("sh")]
_upgrade :
    npins -d "{{tmpl_npins}}" upgrade

[script("sh")]
_update:
    nixpkgs_rev=$(jq -r '.nodes.nixpkgs.locked.rev' "{{git_root}}/flake.lock")
    nonos_rev=$(git -C "{{git_root}}" rev-parse HEAD)
    nonos_branch=$(git -C "{{git_root}}" rev-parse --abbrev-ref HEAD)
    # update the pins
    npins -d "{{tmpl_npins}}" add github NixOS nixpkgs --branch nixos-unstable --at "$nixpkgs_rev"
    npins -d "{{tmpl_npins}}" add github MadMcCrow nonOS --branch "$nonos_branch" --at "$nonos_rev"