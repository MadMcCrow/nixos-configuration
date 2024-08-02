# Auto-update darwin with a single command
{ pkgs, ... }:
let
  # cool script that installs/update for you :
  darwin-install = pkgs.writeShellApplication {
    name = "darwin-install";
    text = builtins.readFile ./scripts/install-darwin.sh;
  };
in {
  #environment.systemPackages = [ darwin-install ];
}
