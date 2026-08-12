set quiet

default_dir := invocation_dir_native() + "/.config"
nix_build_options:="--log-format raw --impure" # internal-json
#nix_features:= "--extra-experimental-features 'nix-command flakes'"
nixconfig := '''
nixconfig() {
    if [ -d "$1" ]; then
        echo "$1/configuration.nix"
    else
        echo "$1"
    fi
}
'''

[no-cd]
default : (build default_dir)


[no-cd, script("sh")]
_check_configuration c:
    {{nixconfig}}
    conf="$(nixconfig "{{c}}")"
    if [ ! -f "$conf" ]; then
        echo "File `$conf` is not there, aborting."
        exit 1
    else
        echo "nix configuration found at `$conf`"
    fi

[no-cd, script("sh")]
build c: (_check_configuration c)
    {{nixconfig}}
    nixos-rebuild build -I nixos-config="$(nixconfig "{{c}}")" {{nix_build_options}} # 2>&1 | nom