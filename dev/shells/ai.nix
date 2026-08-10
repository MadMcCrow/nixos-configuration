# shell to work on the whole project
inputs@{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  servai = pkgs.callPackage ../packages/ai/llama-cpp.nix inputs;
in
mkShellNoCC {
  packages = [ servai ];
  shellHook = "${pkgs.lib.getExe servai}";
}
