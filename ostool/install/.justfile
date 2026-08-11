set dotenv-required
set quiet

cwd := invocation_dir_native() + "/.config"

[no-cd]
default : (build cwd)

build c:
    @nixos-rebuild build -I nixos-config="{{c}}" "$FEATURES" "$LOG" --impure --expr  |& nom