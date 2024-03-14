# Auto-update darwin with a single command
{ pkgs, config, lib, nixpkgs, system, ... }:
let
  # TODO :
  # a command that download the latest version from github
  # and build it
  nixdarwin-rebuild = pkgs.stdenv.mkDerivation {
    name = "nixdarwin-rebuild";
    nativeBuildInputs = [ ];
    buildPhase = "";
    installPhase = "";
  };
in { environment.packages = [ nixdarwin-rebuild ]; }
