# os/default.nix
# build the os tool
{
  lib,
  callPackage,
  callPackages,
  python314,
  pyproject-nix,
  uv2nix,
  pyproject-build-systems,
  ...
}@ args:
let
  # variables
  name = "os";
  workspaceRoot = ./.;
  nixdeps = [(callPackage ../config-keys args)];
  python = python314;

  # uv2nix glue code :
  workspace = uv2nix.lib.workspace.loadWorkspace { inherit workspaceRoot; };
  overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
  pythonSets = (callPackage pyproject-nix.build.packages { inherit python; }).overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.wheel
      overlay
    ]
  );

  # Todo : add the aliases "os-install" == "os install" (and same for update)
in
(callPackages pyproject-nix.build.util { }).mkApplication {
  venv = pythonSets.mkVirtualEnv "${name}-env" (workspace.deps.default ++ nixdeps);
  package = pythonSets.${name};
}
