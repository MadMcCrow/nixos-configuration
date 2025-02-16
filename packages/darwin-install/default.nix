# darwin-install
# basic install/update script written in bash
{ wrapbash ,curl, nix, ... }:
wrapbash {
  name = "darwin-install";
  runtimeInputs = [ nix curl ];
}