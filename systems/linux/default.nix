# linux/default.nix
# all linux systems
{
  addModules,
  addUsers,
  home-manager,
  lanzaboote,
  nixos-hardware,
  nixpkgs,
  self,
  ...
}:
let
  # helper function
  mkX86Linux = mod: rec {
    # maybe we should use a key, pair variable system
    # for now the naming convention comes from this
    # https://xcom.fandom.com/wiki/Category:XCOM_HQ_facilities_(XCOM:_Enemy_Unknown)
    name = value.config.networking.hostName;
    value = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit
          nixpkgs
          nixos-hardware
          addModules
          lanzaboote
          home-manager
          self
          ;
      };
      modules =
        [ mod ]
        # TODO : move user out of here and specify it in devices :
        ++ (addUsers [ "perard" ])
        ++ (addModules [
          "linux"
          "shared"
        ]);
      # TODO : maybe remove linux so that we can have no issues with ISO
    };
  };
in
(builtins.listToAttrs (
  map mkX86Linux [
    # Wyse 5070
    ./DEL.nix
    # NUC 12
    ./NUC.nix
    # Chromebook Pro
    ./SCP.nix
    # Desktop Tower
    # ./TAF.nix # TODO : rename this
  ]
))
# add live iso config :
# // { iso = (mkX86Linux ./ISO.nix).value; }
