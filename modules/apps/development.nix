# development.nix
# 	Add development tools to your system
#   TODO : make this capable of only adding to the user
#          via Home-manager
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  inherit imports;
  cfg = config.apps.development;
  # debug tools
  debugtools.enable = cfg.debugTools.enable;
  debugtools.packages = with pkgs; [ nemiver sysprof ];
  # vs-code
  vscode.enable = if cfg.codeEditor == "vscode" || cfg.codeEditor == "all" then
    true
  else
    false;
  vscode.packages = with pkgs; [
    rnix-lsp
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        jnoortheen.nix-ide
        ms-python.python
        rust-lang.rust-analyzer
        ms-vscode.cpptools
        xaver.clang-format
        llvm-vs-code-extensions.vscode-clangd
      ];
    })
  ];
  # lapce
  lapce.enable = if cfg.codeEditor == "lapce" || cfg.codeEditor == "all" then
    true
  else
    false;
  lapce.packages = with pkgs; [ lapce ];

in {
  imports = [ ../unfree.nix ];
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
    environment.systemPackages =
      (if vscode.enable then vscode.packages else [ ])
      ++ (if lapce.enable then lapce.packages else [ ])
      ++ (if debugtools.enable then debugtools.packages else [ ]);

    # todo : make this work

    unfree.unfreePackages = if vscode.enable then [
      "vscode"
      "vscode-with-extensions"
      "jnoortheen.nix-ide"
      "ms-python.python"
      "github.copilot"
      "rust-lang.rust-analyzer"
      "ms-vscode.cpptools"
      "xaver.clang-format"
      "llvm-vs-code-extensions.vscode-clangd"
      "vscode-extension-ms-vscode-cpptools"
    ] else
      [ ];
    #nixpkgs.config.allowUnfree = true;
  };

}
