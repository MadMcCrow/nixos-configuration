# rustdesk.nix
# 	add rustdesk support to your system
{ config, pkgs, lib, impermanence, ... }:
with builtins;
with lib;
let
  web = config.apps.web;
  cfg = web.rustdesk;
in {
  # interface
  options.apps.web.rustdesk = {
    enable = mkEnableOption
      (mdDoc "Rustdesk, open source replacement for TeamViewer, build in Rust");
    server = mkEnableOption (mdDoc "hosting Rustdesk with docker server");
  };
  #config
  config = lib.mkIf cfg.enable {
    apps.packages = with pkgs;
      [ rustdesk ] ++ (if cfg.server then [ docker-compose docker ] else [ ]);
    virtualisation.docker.enable = cfg.server;
  };
}
