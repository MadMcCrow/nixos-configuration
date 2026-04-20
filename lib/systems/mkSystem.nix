# mkSystem.nix
# base function to build an host
{ nixpkgs, ...} @args :
let
  mkSystemArgs = import ./args.nix args ;
in
tomlPath :
  let
    tomlConfig = builtins.fromTOML (builtins.readFile tomlPath);
  in
  nixpkgs.lib.nixosSystem ({
        system = tomlConfig.system or "x86_64-linux";
      } // mkSystemArgs {
        config = {
          nonOS = tomlConfig;
        };
        moduleNames = [ "core" ];
        #extraArgs = args;
      })
