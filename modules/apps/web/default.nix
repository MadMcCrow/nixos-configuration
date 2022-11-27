# apps/web/default.nix
# 	all the application for networking and scrolling the web
{ pkgs, config, nixpkgs, lib, unfree, ... }:
with builtins;
with lib;
let cfg = config.apps.web;
in {
  #interface
  options.apps.web = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        enable a suite of programs for networking and scrolling the web
      '';
    };
  };
  #imports
  imports = [
    ./firefox.nix
    ./brave.nix
    ./discord.nix
    ./pidgin.nix
    ./signal.nix
    ./rustdesk.nix
  ];
}
