# os/default.nix
# build the os tool
{
  lib,
  callPackages,
  callPackage,
  python312,
  pyproject-nix,
  uv2nix,
  pyproject-build-systems,
  ...
}:
let
  # variables
  name = "os";
  workspaceRoot = ./.;

  # uv2nix glue code :
  workspace = uv2nix.lib.workspace.loadWorkspace { inherit workspaceRoot; };
  overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
  pythonSets = (callPackage pyproject-nix.build.packages { python = python312; }).overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.wheel
      overlay
    ]
  );

  # Todo : add the aliases "os-install" == "os install" (and same for update)
in
(callPackages pyproject-nix.build.util { }).mkApplication {
  venv = pythonSets.mkVirtualEnv "${name}-env" workspace.deps.default;
  package = pythonSets.${name};
}
