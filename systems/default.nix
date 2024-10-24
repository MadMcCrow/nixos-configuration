# systems/default.nix
# build the different systems, MacOS and linux all together
# linux deps :
{ nixos-hardware, ... }@args:
with (import ./linux.nix args);
with (import ./darwin.nix args);
{
  nixosConfigurations = {
    # NUC
    terminus = mkLinux { modules = [ ./NUC ]; };
    # desktop PC
    trantor = mkLinux { modules = [ ./TAF ]; };
    # chromebook
    smyrno = mkLinux { modules = [ ./SCP ]; };

    # live iso for installation :
    iso = mkLinux {
      nixpkgs = nixpkgs-unstable;
      modules = [ ./ISO ];
    };
  };

  darwinConfigurations = {
    # MacBook Air M1
    anacreon = mkMacOS { module = ./MBA; };
  };
}
