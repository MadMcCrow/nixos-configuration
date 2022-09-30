# apps/vscode.nix
# 	vs-code with its extensions
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let cfg = config.apps.vscode;
in {
  options.apps.vscode.enable = lib.mkOption {
    type = types.bool;
    default = false;
    description = "enable vs code if true";
  };
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
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
    # does not work
    # nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    #  "jnoortheen.nix-ide"
    #  "ms-python.python"
    #  "github.copilot"
    #  "rust-lang.rust-analyzer"
    #  "ms-vscode.cpptools"
    #  "xaver.clang-format"
    #  "llvm-vs-code-extensions.vscode-clangd"
    #];
    # works but is not cool
    nixpkgs.config.allowUnfree = true;
  };
}
