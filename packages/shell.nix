{ pkgs ? import <nixpkgs> { } }:
let
  pythonPackages = [ pkgs.python311 ]
    ++ (with pkgs.python311Packages; [ sh rich btrfsutil ]);
in pkgs.mkShell {
  buildInputs = pythonPackages;
  inputsFrom = (builtins.attrValues (pkgs.callPackages ./default.nix { }));
}
