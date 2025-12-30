# build 

Useful commands :

```bash
# to install it to a machine
> nixos-install --flake github:MadMcCrow/nixos-configuration.#hostname
# to test if it will produce a valid generation
> nixos-rebuild dry-activate --flake .#
# to update all inputs in flake.lock
>  nix build --recreate-lock-file
```
