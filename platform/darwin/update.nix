# Auto-update darwin with a single command
{ pkgs, config, lib, nixpkgs, system, ... }:
let
  # cool script that installs/update for you :
  darwin-install = pkgs.writeShellApplication {
    name = "darwin-install";
    text = builtins.readFile ./scripts/install-darwin;
  };
in { environment.systemPackages = [ darwin-install ]; }
