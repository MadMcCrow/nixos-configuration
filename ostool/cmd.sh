#!/usr/bin/env sh
# shellcheck disable=SC2204,SC2205
set +x

# pick a directory if none is provided
pick_dir() {
    if [ -z "$1" ]; then
        result=$(
            fzf --walker=dir,hidden \
                --print-query \
                --query="${1:-}" \
                --prompt='init directory > '
        )
        query=$(printf '%s\n' "$result" | sed -n '1p')
        selected=$(printf '%s\n' "$result" | sed -n '2p')
        printf '%s\n' "$(echo "${selected:-$query}" | sed 's:/*$::')"
    else
        printf '%s\n' "$1"
    fi
}


# find the configuration file within a directory
_configuration() {
    if [ -f "$1/configuration.nix" ]; then
        printf '%s\n' "$1/configuration.nix"
        return 0
    fi
    return 1
}

# find the configuration file within a directory
get_config() {
    if [ "$#" -gt 0 ]; then
        path=$1

        if [ -f "$path" ]; then
            printf '%s\n' "$path"
            return 0
        fi

        _configuration "$path"
        return $?
    fi

    for path in \
        "/etc/nonOS" \
        "/etc/nonos" \
        "/etc/nixos" \
        "$HOME/.config/nonOS" \
        "$HOME/.config/nix" \
        "$HOME/.config/nixos" \
        ".config"
    do
        if _configuration "$path"; then
            return 0
        fi
    done

    printf '%s\n' "configuration.nix not found" >&2
    return 1
}

init_pin() {
    npins_dir="$1/npins"
    echo "updating nonOS pin"
    npins -d "$npins_dir" update nonOS

    nonos_path=$(nix eval --raw --impure --expr "(import $npins_dir {}).nonOS.outPath")
    locked_rev=$(jq -r '.nodes.nixpkgs.locked.rev' "$nonos_path/flake.lock")
    current_rev=$(jq -r '.pins.nixpkgs.revision' "$npins_dir/sources.json")

    if [ "$locked_rev" = "$current_rev" ]; then
        echo "nixpkgs already up to date ($current_rev)"
        return 0
    fi

    git_nixpkgs="https://github.com/NixOS/nixpkgs.git"
    cache=$(mktemp -d)
    git -C "$cache" init -q
    git -C "$cache" fetch -q --depth 1 $git_nixpkgs "$current_rev"
    current_ts=$(git -C "$cache" log -1 --format=%ct FETCH_HEAD)

    git -C "$cache" fetch -q --depth 1 $git_nixpkgs "$locked_rev"
    locked_ts=$(git -C "$cache" log -1 --format=%ct FETCH_HEAD)

    rm -rf "$cache"

    if [ "$locked_ts" -gt "$current_ts" ]; then
        echo "nonOS's nixpkgs ($locked_rev) is newer, updating"
        npins -d "$npins_dir" add github NixOS nixpkgs --branch nixos-unstable --at "$locked_rev" --name nixpkgs
    else
        echo "local nixpkgs already newer or equal, skipping"
    fi
}

hardware_config() {
    hc="$1/hardware-configuration.nix"
    touch "$hc"
    if command -v nixos-generate-config >/dev/null 2>&1; then
        echo "generating hardware config"
        # generate config, clean it and save it to file
        sudo env PATH="$PATH" nixos-generate-config --no-filesystems --show-hardware-config \
        | sed \
            -e 's/, modulesPath//' \
            -e 's/(modulesPath + "\/installer\/scan\/not-detected.nix")//' \
        > "$hc"
    else
        echo "writing empty hardware config ('nixos-generate-config' is not available)"
        echo '_ : {}' > "$hc"
    fi
}

copy_template() {
    echo "copy template config"
    cp --no-preserve=mode,ownership "$1/configuration.nix" "$2" -Rf
    cp --no-preserve=mode,ownership "$1/npins" "$2" -Rf
    chmod 755 -R "$2"
}

build_config() {
    # nix_build_options="--log-format raw --impure" # internal-json
    nixos_build_options="--no-reexec --impure --show-trace"
    #nix_features:= "--extra-experimental-features 'nix-command flakes'"
    conf="$(get_config "$1")"
    echo "building configuration \"$conf\""
    nixos-rebuild build $nixos_build_options -I nixos-config="$conf"  # 2>&1 | nom
    # nix-build '<nixpkgs/nixos>' -A system -I nixos-config="$conf"
}



# Check if the function exists (bash specific)
if command -v "$1" >/dev/null 2>&1
then
    # call arguments verbatim
    "$@"
else
    echo "'$1' is not a known command or function name" >&2
    exit 1
fi