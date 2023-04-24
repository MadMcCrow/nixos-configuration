# development.nix
# 	Add development tools to your system
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  aps = config.apps;
  cfg = aps.development;
in {
  # interface
  options.apps.development.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      Add development tools to your system
    '';
  };
  # config
  config = mkIf cfg.enable {
    # add nix language support
    apps.packages = with pkgs; [ rnix-lsp ];
  };

  imports = [ ./debugtools.nix ./github.nix ./vscode.nix ];
}
