# shell environment to use/develop with secrets
{ pkgs ? import <nixpkgs> { }, 
pycnix? (pkgs.fetchFromGitHub {
          owner = "MadMcCrow";
          repo = "pycnix";
          rev = "3fad6ed6634e2261449b57d1a88ddfaeb0f6ba11";
          sha256 = "";
        }), ... }:
with builtins;
let
  # package secret script
  nixos-age-secret = import ./age-secret.nix {inherit pkgs pycnix;};
in pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  buildInputs = [ nixos-age-secret ];
}
