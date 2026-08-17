#!/usr/bin/env sh
set +x

_configuration() {
    if [ -f "$1/configuration.nix" ]; then
        printf '%s\n' "$1/configuration.nix"
        return 0
    fi
    return 1
}

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


init_dir() {
    # make sure directory exists and is empty
    mkdir -p "$1" && true
    rm -rf "$1/.*" && true
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

format() {
    # TODO : treefmt !
    echo "format files in $1 using nix tools"
    files=$(find "$1" -type f -name '*.nix' -print)
    # deadnix
    if command -v deadnix >/dev/null 2>&1; then
        printf "\rdeadnix formatting"
        deadnix -eq  "$files"
    fi
    # alejandra
    if command -v alejandra >/dev/null 2>&1; then
        printf "\ralejandra formatting"
        alejandra -q  "$files"
    fi
    # nixfmt
    if command -v nixfmt >/dev/null 2>&1; then
        printf "\rnixfmt formatting"
        nixfmt -q  "$files"
    fi
}

build() {
    nix_build_options="--log-format raw --impure" # internal-json
    #nix_features:= "--extra-experimental-features 'nix-command flakes'"
    conf="$(./config.sh "$@")"
    nixos-rebuild build --file "$conf" "$nix_build_options" # 2>&1 | nom
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