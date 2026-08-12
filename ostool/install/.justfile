set dotenv-required
set quiet

default_dir := invocation_dir_native() + "/.config"

[no-cd]
default : (build default_dir)

build c:
    @nixos-rebuild build -I nixos-config="{{c}}" "$FEATURES" "$LOG" --impure --expr  |& nom