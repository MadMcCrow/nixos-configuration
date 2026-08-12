# flake part module for dev shells
{ self, withSystem, inputs, ... }: {
  perSystem = { pkgs, lib, system, ... } :
  with builtins;
  with pkgs;
let
  # local llm support :not recommended because it's heavy
  llmserver = callPackage (self + "/packages/ai/llama-cpp.nix") inputs;
in
  {
    # built dev shell with everything
    devShells  = {
      # default is for common dev
      default = mkShellNoCC {
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
      ];

      shellHook = ''
        git_root="$(git rev-parse --show-toplevel)"
        echo "updating every pin in $git_root"
        cd $git_root
        ${pkgs.lib.getExe pkgs.just}
      '';
    };

    llm = mkShellNoCC {
      packages = [
          llmserver
      ];
      shellHook = ''
        echo "starting llm server"
        ${pkgs.lib.getExe llmserver} &
      '';
    };
  };
   };
}
