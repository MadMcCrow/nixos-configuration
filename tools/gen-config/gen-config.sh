#!/bin/env sh
# generate the hardware configuration
# this is only intended for debugging purposes
echo "detect config and generate hardware-config";
sudo nixos-generate-config --no-filesystems --show-hardware-config | tee ./hardware-configuration.nix
echo "writing template config"
# generate the list of nonOS options
nix eval .#nixosModules.core --apply 'module : builtins.attrNames  ((import <nixpkgs> {}).lib.evalModules {
  modules = [ module  { _module.check = false; }];
}).options.nonOS
' --impure