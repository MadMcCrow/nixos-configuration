# My [NIXOS](https://nixos.org/) configuration(s)

This repo contains the necessary Nix modules to build my systems. I do not recommend you use this as a base for your system, as it's not really well documented and written to fill my specific needs.

This config is now working with flakes, allowing a more modular, reproducible and simpler installation.

## flakes
find all usefull commands in the [manual](https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-flake-update.html)

```bash
# to install it to a machine
> nixos-install --flake github:MadMcCrow/nixos-configuration.#hostname
# to test if it will produce a valid generation
> nixos-rebuild dry-activate --flake .#
# to update all inputs in flake.lock
>  nix build --recreate-lock-file
```

## modules

Various modules define options to enable programs and services, as well as users, to make a common environment on all my machines

## Systems

systems are specific configuration based on specific hardware. the `configuration.nix` is the configuration file that made the system boot originally post install.

## Impermanence

On linux, my machines use the concept of impermanence as described [here](https://grahamc.com/blog/erase-your-darlings).

## building and caching

My configuration is automatically updated and build by a github action :
![flake-update](https://github.com/MadMcCrow/nixos-configuration/actions/workflows/flake-update.yml/badge.svg)

The artifacts of that build are cached on cachix [here](https://app.cachix.org/cache/nixos-configuration).


## TODO
these would be the next improvements for this repo :
 - [ ] Make a documentation
 - [ ] split `Modules` folder to `Darwin` `Nixos` and `Nix`
 - [X] Move scripts to a separate folder
 - [ ] Update github actions
 - [ ] Move nextcloud to a separate flake
 - [ ] Make gnome and dconf a separate flake
