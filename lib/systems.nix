# modules.nix
# use import-tree magic to make our custom TOML parser
{
  self,
  lib,
  nixpkgs,
  ...
}:
with lib;
{
  # nixosSystem wrapped
  mkSystem =
    args@{
      system ? "x86_64-linux",
      ...
    }:
    nixpkgs.lib.nixosSystem (
      args
      // {
        inherit system;
        specialArgs = {
          # expose our own flake outputs
          nonOS = self.outputs;
        }
        // (args.specialArgs or { });
      }
    );

  # make a custom appliance system (ie. no nix store)
  mkAppliance = _: throw "not implemented yet !";

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
