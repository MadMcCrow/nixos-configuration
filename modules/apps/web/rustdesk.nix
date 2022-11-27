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
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description =
        "Rustdesk is an open source replacement for TeamViewer, build in Rust";
    };
    server = lib.mkOption {
      type = types.bool;
      default = false;
      description = "should we deploy rustdesk with docker";
    };
  };
  #config
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs;
      [ rustdesk ] ++ (if cfg.server then [ docker-compose docker ] else [ ]);
    virtualisation.docker.enable = cfg.server;
  };
}
