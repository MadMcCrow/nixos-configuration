# modules.nix
# use import-tree magic to make our custom TOML parser
inputs@ {
  self,
  lib,
  import-tree,
  nixpkgs,
  ...
} :
let
  # selective imports
  nonlib  = import ./options.nix inputs;
  version = import ./version.nix inputs;
  nonpkgs = import ./packages.nix inputs;

  # os name
  inherit (version) name;

  # helper function for modules;
  nonOS = curpos : args@{config, ...} :
  with lib;
  let
    dir = traceVal (builtins.toString self);
    relpath = traceVal (removePrefix dir curpos.file);
    pathlist = splitString "/" (removeSuffix ".nix" relpath );
  in {
    # cfg getter
    cfg = lib.attrByPath pathlist config config.${name};
    # set options
    options = optAttr : lib.setAttrByPath ([name] ++ pathlist) optAttr;
    # the dotted path
    path = lib.string.join "." pathlist;
    # get the os status
    inherit (version) version name status;
  };

  importModule = modpath : (import-tree (self + "/modules"));

in
rec {
  # parameters for a nixpkgs.lib.nixosSystem call;
  # This allows making sure that we can call
  # lib.evalModules with the same attributes
  sysArgs = config : {
      system = config.system or "x86_64-linux";
       specialArgs = {
       inherit nonlib nonOS nonpkgs;
     };
    modules = [

      {
        # allow everything to handle errors and warnings ourselves.
        options.${name} = lib.mkOption {
          type = lib.types.submodule {
            freeformType = lib.types.attrsOf lib.types.anything;
          };
          description = "${name} configuration root (populated from TOML)";
        };
      }
      config
    ];
    };

# make a traditional nixOS
mkNixosSystem = tomlPath :
nixpkgs.lib.nixosSystem (sysArgs {
    ${name} = builtins.fromTOML (builtins.readFile tomlPath);
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
    '';

}
