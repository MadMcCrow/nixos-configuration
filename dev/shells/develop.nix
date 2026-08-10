# shell to work on the whole project
inputs@{
  pkgs ? import <nixpkgs> { },
  self ? ../..,
  ...
}:
with builtins;
with pkgs;
let
  # update packages pins
  pkgsupd = callPackage (self + "/packages/_npins/update.nix") inputs;
  # update template pins
  tpltupd = (callPackage (self + "/ostool/template") inputs).update-template;
in
mkShellNoCC {
  packages = [
    deadnix
    nixfmt-tree
    npins
    just
    shellcheck
    deadnix
    statix
    nixfmt-tree
    nixos-install-tools
    npins
    just
    pkgsupd
    tpltupd
  ];

    shellHook = ''
      ${pkgs.lib.getExe pkgsupd}
      ${pkgs.lib.getExe tpltupd}
    '';

}
