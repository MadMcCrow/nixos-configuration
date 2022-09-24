# apps/vscode.nix
# 	vs-code with it's extensions
{ pkgs, config, lib, ...}:
with lib;
with builtins;
let
  cfg = config.coding.vscode;
in {
  options.coding.vscode.enable = lib.mkEnableOption "vscode";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          ms-python.python
          github.copilot
          rust-lang.rust-analyzer
          ms-vscode.cpptools
          xaver.clang-format
          llvm-vs-code-extensions.vscode-clangd
        ]
      })
    ];
  };
}
