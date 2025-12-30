{ nixpkgs, nixos-hardware, ... } : {

}

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
    ++ (addModules [
      "linux"
      "shared"
    ]);
