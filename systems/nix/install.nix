{ nixos-install-tools, writeShellApplication, ... } :
writeShellApplication {
  name = "nonos-install";

  runtimeInputs = [
    nix
    nixos-install-tools
  ];

  text = ''

  '';
