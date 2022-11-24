# development.nix
# 	Add development tools to your system
# todo : simplify and improve
{ config, pkgs, lib, unfree, ... }:
with builtins;
let
  # cfg
  cfg = config.apps.development;
in {
  # imports
  imports = [ ./debugtools.nix ./github.nix ./vscode.nix ./lapce.nix ];

  # interface
  options.apps.development = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Add development tools to your system";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (with pkgs; [ rnix-lsp ]);
  };

}
