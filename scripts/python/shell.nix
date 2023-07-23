{ pkgs ? import <nixpkgs> {} }:
let
python = import ./python.nix {inherit pkgs;};
test = pkgs.writeText "test" ''print ("hello world")'';
cython-test = python.mkPyScript "test_cython" test;
in
pkgs.mkShell {
    # nativeBuildInputs is usually what you want -- tools you need to run
    nativeBuildInputs = with pkgs.buildPackages; [ cython-test ];
}
