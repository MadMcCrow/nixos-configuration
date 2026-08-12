set quiet

cwd := invocation_dir_native() + "/.config"
template := env("OS_TEMPLATE", "../template/src")


[no-cd]
default : (dir cwd)

_init_dir d :
    # make sure directory exists and is empty
    mkdir -p "{{d}}" && true
    rm -rf "{{d}}/.*" && true

_format d:
    #!/usr/bin/env sh
    echo "format files in {{d}} using nix tools"
    files=$(find "{{d}}" -type f -name '*.nix' -print)
    deadnix -eq  $files
    alejandra -q $files
    nixfmt -sq   $files

_hardware-config d : (_init_dir d)
    echo "generating hardware config"
    touch "{{d}}/hardware-configuration.nix"
    # generate config, clean it and save it to file
    sudo env PATH="$PATH" nixos-generate-config --no-filesystems --show-hardware-config \
      | sed \
        -e 's/, modulesPath//' \
        -e 's/(modulesPath + "\/installer\/scan\/not-detected.nix")//' \
      > "{{d}}/hardware-configuration.nix"

_template-config d : (_init_dir d)
    cp --no-preserve=mode,ownership "{{template}}/configuration.nix" "{{d}}" -Rf
    cp --no-preserve=mode,ownership "{{template}}/npins" "{{d}}" -Rf
    chmod 755 -R "{{d}}"

[parallel]
_generate d: (_template-config d) (_hardware-config d)

dir d: (_generate d) (_format d)