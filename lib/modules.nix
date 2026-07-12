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

  version = import ./version.nix inputs;
  # os name
  inherit (version) name;

  # helper function/attrset for modules;
  ${name} = curpos : args@{enabled ? true, config, ...} :
   with lib;
   let
     # get list out of curpos
     dir = traceVal (builtins.toString self);
     pathlist = splitString "/" (removeSuffix ".nix" (removePrefix dir curpos.file) );
     path = lib.string.join "." pathlist;
     # filter globals out of attrs
     filterGlobals = enabled: attrs: filterAttrs (n: v: if enabled then hasPrefix "_" n else !hasPrefix "_" n) attrs;
   in {
     # cfg getter gets globals and specific
     cfg = (filterGlobals true config.${name})
     // (lib.attrByPath pathlist {} config.${name};
     # set options
     options = optAttr: {
       ${name} =
         # add globals
        (filterGlobals true optAttr)
        # and then we add all the other attribute by their path prefixed
        // (lib.setAttrByPath pathlist
          (filterGlobals false optAttr // {
          enable = mkEnableOption "enable ${path}" // {default = enabled; }
        }));
     };
     # get the os status
     inherit (version) version name status;
     # the dotted path
     inherit path;
     # added libraries
     lib  = import ./options.nix inputs;
     # added packages
     pkgs = import ./packages.nix inputs;
   };

in
{
  # the final nixos system.
  mkNixosSystem = config : nixpkgs.lib.nixosSystem {
      system = config.system or "x86_64-linux";
       specialArgs = {
       inherit ${name};
     };
    modules = [
      (import-tree (self + "/modules"))
      config
    ];
    };

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
