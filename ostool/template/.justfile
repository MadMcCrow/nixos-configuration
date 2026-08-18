git_root:="$(git rev-parse --show-toplevel)"
tmpl_npins:=  env("OS_TEMPLATE", "./") + "/npins"

[script("sh")]
update:
    npins -d "{{tmpl_npins}}" upgrade
    nixpkgs_rev=$(jq -r '.nodes.nixpkgs.locked.rev' "{{git_root}}/flake.lock")
    nonos_rev=$(git -C "{{git_root}}" rev-parse HEAD)
    nonos_branch=$(git -C "{{git_root}}" rev-parse --abbrev-ref HEAD)
    # update the pins
    npins -d "{{tmpl_npins}}" add github NixOS nixpkgs --branch nixos-unstable --at "$nixpkgs_rev"  --name nixpkgs
    npins -d "{{tmpl_npins}}" add github MadMcCrow nonOS --branch "$nonos_branch" --at "$nonos_rev" --name nonOS
    # no need to add flake compat for the user, for now
    #npins -d "{{tmpl_npins}}" add git https://git.lix.systems/lix-project/flake-compat --branch main --forge forgejo --name flake-compat