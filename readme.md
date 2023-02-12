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

modules define options to enable programs and services, as well as users

## Systems

systems are specific configuration based on specific hardware. It's the configuration that made the system boot originally

## TODO
these would be the next improvements for this repo :
 - [ ] building with github actions (see [this setup](https://github.com/NobbZ/nixos-config/blob/main/.github/workflows/flake-update.yml))
 - [ ] caching with cachix
 - [ ] moving apps to home-manager
 - [ ] adding support for aarch64-darwin (for my macbook air 2020).
 - [ ] Setup my server, Dreamcloud with it
 - [ ] Support KDE desktop environment
