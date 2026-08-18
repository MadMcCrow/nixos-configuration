#!/usr/bin/env just --justfile
#
# cmd.just :
#       main entry point for nonOS commands
#
set quiet # do not echo commands
set lazy # do not evaluate parameters if you don't need them

# recall immediately the same file with same binary
rejust := quote(just_executable()) + " --justfile " + quote(justfile())
template := env("OS_TEMPLATE", "./template/src")
commands := env("OS_CMD", module_directory() + "/cmd.sh")


# default command is interactive
[default, no-cd]
_ :
    {{rejust}} --choose


# initialize directory as a nonOS config
[no-cd, script]
init d="":
    #!/usr/bin/env sh
    # handle interactivity :
    target=$("{{commands}}" "pick_dir" "{{d}}")
    echo "initializing config at $(realpath $target)"
     #   1) clear target directory,
    {{rejust}} _clean-dir $target
    #   2.a) copy the template
    #   2.b) generate the hardware configuration
    {{rejust}} _generate $target
    #   3.a) correct the pinned version of nonOS and nixpkgs
    #   3.b) format the nix files
    {{rejust}} format $target

# build target configuration locally
[no-cd, script]
build d="":
    #!/usr/bin/env sh
    # handle interactivity :
    target=$("{{commands}}" "pick_dir" "{{d}}")
    # will call nixos-rebuild
    "{{commands}}" build_config $target

# format files in a directory if formatter is defined
[no-cd, script]
format d="" :
    #!/usr/bin/env sh
    # handle interactivity :
    target=$("{{commands}}" "pick_dir" "{{d}}")
    # call formatter if available
    if [ -n "{{env("FORMATTER", "")}}" ]; then
        echo "formatting files"
        "{{env("FORMATTER")}}" $target -qc
    fi


################# Private recipes #################
[no-cd]
_clean-dir d :
    # make sure directory exists and is empty
    mkdir -p "{{d}}" && true
    rm -rf "{{d}}/.*" && true


[no-cd]
_init-pin d:
    -"{{commands}}" init_pin "{{d}}"

[no-cd]
_hardware-config d :
    "{{commands}}" hardware_config "{{d}}"


[no-cd]
_template-config d :
    echo "copy template config"
    mkdir -p "{{d}}" && true
    cp --no-preserve=mode,ownership "{{template}}/configuration.nix" "{{d}}" -Rf
    cp --no-preserve=mode,ownership "{{template}}/npins" "{{d}}" -Rf
    chmod 755 -R "{{d}}"

[no-cd, parallel]
_generate d: (_template-config d) (_hardware-config d)


[no-cd, parallel]
_init_fixup d : (format d) (_init-pin d)