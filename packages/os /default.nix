# os/default.nix
# build the os tool
{ lib, python312, pyproject-nix, uv2nix, pyproject-build-systems, ... }:
let
# variables
name = "os";
rootdir = ./.;

# uv2nix glue code :
workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = rootdir; };
overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
pythonSets = pkgs.callPackage pyproject-nix.build.packages { python = python312; };

# Todo : add the aliases "os-install" == "os install" (and same for update)
in (pkgs.callPackages pyproject-nix.build.util { }).mkApplication {
    venv = pythonSets.mkVirtualEnv "${name}-env" workspace.deps.default;
    package = pythonSets.${name};
  };
}
