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
    environment.systemPackages = with pkgs;
      [
        rnix-lsp
        (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; [
            jnoortheen.nix-ide
            ms-python.python
            github.copilot
            rust-lang.rust-analyzer
            ms-vscode.cpptools
            xaver.clang-format
            llvm-vs-code-extensions.vscode-clangd
          ];
        })
      ];
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["vscode-with-extensions"];

  };
}
