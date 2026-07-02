# mkSystem.nix
#   base function to build an host
# returns :
#   all the meaningful outputs
{ nixpkgs, ... } :
let
  outputs = with nixosSystem.config.system.build; [
    diskoScript
    toplevel
    installBootLoader
  ];

in nixosSystem.pkgs.runCommand "system-${nixosSystem.config.networking.hostName}" {} ''
     mkdir -p $out

     ${builtins.concatStringsSep "\n"
       (map (drv: "ln -s ${drv} $out/${builtins.getName drv}") outputs)}
   ''
