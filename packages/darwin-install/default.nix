# basic install script written in sh
{ writeShellApplication, curl, ... }:
writeShellApplication {
  name = "darwin-install";
  runtimeInputs = [ curl ];
  text = builtins.readFile ./script.sh;
}
