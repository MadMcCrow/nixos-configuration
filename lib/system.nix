# modules.nix
# use import-tree magic to make our custom TOML parser
inputs@ {
  self,
  lib,
  import-tree,
  nixpkgs,
  ...
} :
{
  # create a nixos system
  mkNixosSystem = tomlPath :
  let
    tomlConfig = builtins.readfile (builtins.fromToml tomlPath);
    modules = import ./modules.nix inputs;
  in
    nixpkgs.lib.nixosSystem {
    # pass our helpers,
    specialArgs = rec {
        nonlib = lib.foldl' (acc: new: acc // import new inputs) {} [
        ./options.nix
        ./modules.nix
        ./version.nix
      ];
      nonpkgs = import ./packages.nix inputs;
      # shortcut
      inherit (nonlib) nonOS;
    };
    system = tomlConfig.system or "x86_64-linux";
    modules = [
      (import-tree (self + "/modules"))
      {
        config.nonOS = tomlConfig;
      }
    ];
    });


# make a custom appliance system (ie. no nix store)
mkAppliance =  {nixpkgs, ...} :
 throw "not implemented yet !";

# create a symlinked output of a nixosSystem
joinSystemOutputs = system :
 let
  name = "system-${system.config.networking.hostName}";
   outputs = with system.config.system.build; [
     diskoScript
     toplevel
     installBootLoader
   ];
  in system.pkgs.runCommand name {} ''
      mkdir -p $out
      ${builtins.concatStringsSep "\n"
        (map (drv: "ln -s ${drv} $out/${builtins.getName drv}") outputs)}
    ''

}
