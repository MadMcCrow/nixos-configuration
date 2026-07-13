# modules.nix
# use import-tree magic to make our custom TOML parser
inputs@ {
  self,
  lib,
  import-tree,
  nixpkgs,
  ...
} :
with lib;
let
  # selective imports
  version = import ./version.nix inputs;
  # os name
  inherit (version) name;

  # where the module are stored
  moduleRoot = (self + "/modules");

  # helper function/attrset for modules;
  ${name} = curpos : args@{config, ...} :
   let
     # get list out of curpos
     nixfile = removeSuffix "/default.nix" (removePrefix moduleRoot curpos.file);
     pathlist = splitString "/" (removeSuffix ".nix" nixfile);
     path = lib.string.join "." pathlist;

     # filter globals out of attrs
     filterGlobals = attrs: neg: filterAttrs (n: _: (hasPrefix "_" n) != neg) attrs;

   in {
     # cfg getter gets globals and specific
     cfg = (filterGlobals true config.${name})
     // (attrByPath pathlist {} config.${name});
     # set options
     options = optAttr: {
       ${name} =
         # add globals
        (filterGlobals true optAttr)
        # and then we add all the other attribute by their path prefixed
        // (setAttrByPath pathlist
          (filterGlobals false optAttr // {
          enable = mkEnableOption "${name}.${path}" // {default = enabled; }
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
     # quick getter
     enabled = attrByPath pathlist false ;

     # test if this module is enabled
     enabled = let
      isEnabledAncestor = p:
      let
       node = lib.attrByPath (p ++ ["enable"]) null config.${name};
      in
        if node == false then false
        else if p == [] then true
        else isEnabledAncestor (lib.init p);
     in config.${name}.enable && isEnabledAncestor pathlist
   };

in
{
  # the final nixos system.
  mkNixosSystem = config : nixpkgs.lib.nixosSystem {
      system = config.system;
       specialArgs = {
       inherit ${name};
     };
    modules = [
      (import-tree moduleRoot)
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
