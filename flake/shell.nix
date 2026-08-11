# flake part module for dev shells
{ withSystem, inputs, ... }: {
  perSystem = { pkgs, lib, system, ... } :
  with builtins;
  with pkgs;
let
  # local llm support
  llmserver = callPackage (self + "/packages/ai/llama-cpp.nix") inputs;
  # update packages pins
  pkgsupd = callPackage (self + "/packages/_npins/update.nix") inputs;
  # update template pins
  ostemplate = callPackage (self + "/ostool/template") inputs;
in
  {
    # built dev shell with everything
    devShells.default = mkShellNoCC {
      packages = [
        deadnix
        nixfmt-tree
        npins
        just
        shellcheck
        deadnix
        statix
        nixfmt-tree
        nixos-install-tools
        npins
        just
        pkgsupd
        ostemplate.update-template
        llmserver
      ];

      shellHook = ''
        ${pkgs.lib.getExe pkgsupd}
        ${pkgs.lib.getExe ostemplate.update-template }
      '';
    };
  };
}
