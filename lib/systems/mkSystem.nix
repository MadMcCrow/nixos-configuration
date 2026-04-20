# mkSystem.nix
# base function to build an host
{ nixpkgs, ...} @args :
let
  mkSystemArgs = import ./args.nix args ;
in
systemArgs :
  nixpkgs.lib.nixosSystem ({
        system = "x86_64-linux";
      } // mkSystemArgs systemArgs);
