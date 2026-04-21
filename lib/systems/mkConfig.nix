 # mkConfig.nix
 # Arguments for mkSystem.nix and mkAppliance.nix
 # This allows to pass common arguments to both functions.
 { self, ... } @args :
 # create the attribute set for "nixpkgs.lib.nixosSystem"
tomlPath :
let
  tomlConfig = builtins.fromTOML (builtins.readFile tomlPath);
in
 {
   # we default to "x86_64-linux" if not specified in the TOML config
   system = tomlConfig.system or "x86_64-linux";
   specialArgs = extraArgs;
   modules = [
     self + "/modules"
     {
       # do all the custom parsing there :
       nonOS = tomlConfig;
     }
   ]
 }
