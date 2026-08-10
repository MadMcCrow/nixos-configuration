set quiet

cwd := invocation_dir_native() + "/.config"

[no-cd]
default : (dir cwd)

_ensure_dir d :
    # make sure directory exists
    mkdir -p "{{d}}" && true

_format d:
    #!/usr/bin/env sh
    echo "format files in {{d}} using nix tools"
    files=$(find "{{d}}" -type f -name '*.nix' -print)
    deadnix -eq  $files
    alejandra -q $files
    nixfmt -sq   $files

_hardware-config d : (_ensure_dir d)
    echo "generating hardware config"
    touch "{{d}}/hardware-configuration.nix"
    # generate config, clean it and save it to file
    sudo env PATH="$PATH" nixos-generate-config --no-filesystems --show-hardware-config \
      | sed \
        -e 's/, modulesPath//' \
        -e 's/(modulesPath + "\/installer\/scan\/not-detected.nix")//' \
      > "{{d}}/hardware-configuration.nix"

_template-config d : (_ensure_dir d)
    cp "./template/etc/" "{{d}}"/ -Rf

[parallel]
_generate d: (_template-config d) (_hardware-config d)

dir d: (_generate d) (_format d)