 # args.nix
 # Arguments for mkSystem.nix and mkAppliance.nix
 # This allows to pass common arguments to both functions.
 { _ } :
 # create the attribute set for "nixpkgs.lib.nixosSystem"
{ moduleNames, config, extraArgs ? {}, overrides ? {} } :
 {
   specialArgs = extraArgs;
   modules = (map (x: ./ + x ) moduleNames) ++ [config];
 };
