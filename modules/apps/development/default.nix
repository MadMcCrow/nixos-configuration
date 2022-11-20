# development.nix
# 	Add development tools to your system
# todo : simplify and improve
{ config, pkgs, lib, unfree, ... }:
with builtins;
with lib;
let
  # cfg shortcut
  cfg = config.apps.development;
  # debug tools
  debugtools.enable = cfg.debugTools.enable;
  debugtools.packages = with pkgs; [ nemiver sysprof ];
  # vs-code
  vscode.enable = cfg.codeEditor == "vscode" || cfg.codeEditor == "all";
  vscode.module = import ./vscode.nix { inherit config lib pkgs; };
  vscode.packages = vscode.module.packages;
  vscode.unfree = vscode.module.unfree;
  # lapce
  lapce.enable = cfg.codeEditor == "lapce" || cfg.codeEditor == "all";
  lapce.packages = with pkgs; [ lapce ];

in {
  # interface
  options.apps.development = {
    enable = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Add development tools to your system";
    };

    # code editor of choice
    codeEditor = lib.mkOption {
      type = types.enum [ "lapce" "vscode" "all" ];
      default = "vscode";
      description = "Set the code editor you want to have";
    };

    # debug tools
    debugTools.enable = lib.mkOption {
      type = types.bool;
      default = true;
      description =
        "Debug tools are GUI tools to help with debugging and performance measures";
    };

    github.enable = lib.mkOption {
      type = types.bool;
      default = true;
      description = "if true we add gh to your path";
    };

  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = (with pkgs; [ rnix-lsp ])
      ++ (if debugtools.enable then debugtools.packages else [ ])
      ++ (if lapce.enable then lapce.packages else [ ])
      ++ (if vscode.enable then vscode.packages else [ ]);

    unfree.unfreePackages = if vscode.enable then vscode.unfree else [ ];
  };

}
