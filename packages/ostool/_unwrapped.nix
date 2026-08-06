# ostool/_python.nix
# python glue code to produce the package
{
  self,
  lib,
  callPackage,
  callPackages,
  python314,
  uv2nix,
  pyproject-nix,
  pyproject-build-systems,
  ...
}:
let
  # variables
  python = python314;

  # uv2nix glue code :
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = self + "/tools/os"; };
  overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
  pythonSets = (callPackage pyproject-nix.build.packages { inherit python; }).overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.wheel
      overlay
    ]
  );
in
(callPackages pyproject-nix.build.util { }).mkApplication {
  venv = pythonSets.mkVirtualEnv "ostool-env" workspace.deps.default;
  package = pythonSets.ostool;
}
