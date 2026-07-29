# modules.nix
# use import-tree magic to make our custom TOML parser
inputs@{
  self,
  lib,
  nixpkgs,
  ...
}:
with lib;
let
  # selective imports
  version = import ./version.nix inputs;
  modules = import ./modules.nix inputs;
in
{
  # shorter invocation
  mkSystem =
    args@{ config, ... }:
    # nixos system wrapped
    nixpkgs.lib.nixosSystem (
      (removeAttrs args [ "config" ])
      // {
        system = args.system or "x86_64-linux";
        specialArgs = {
          nonOS = self.outputs;
        };
        modules = [ config ];
      }
    );

  # make a custom appliance system (ie. no nix store)
  mkAppliance = { nixpkgs, ... }: throw "not implemented yet !";

  # create a symlinked output of a nixosSystem
  joinSystemOutputs =
    system:
    let
      name = "system-${system.config.networking.hostName}";
      outputs = with system.config.system.build; [
        diskoScript
        toplevel
        installBootLoader
      ];
    in
    system.pkgs.runCommand name { } ''
      mkdir -p $out
      ${builtins.concatStringsSep "\n" (map (drv: "ln -s ${drv} $out/${builtins.getName drv}") outputs)}
    '';
}
