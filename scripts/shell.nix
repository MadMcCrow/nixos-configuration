{ pkgs ? import <nixpkgs> {} }:
let
python = import ./python.nix {inherit pkgs;};
cython-test = python.mkPyFile ./cython-test.py;
in
pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ cython-test ];
}
