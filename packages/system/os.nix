# os/default.nix
# build the os tool
{
  self,
  lib,
  callPackage,
  callPackages,
  symlinkJoin,
  python314,
  pyproject-nix,
  uv2nix,
  pyproject-build-systems,
  makeWrapper,
  ...
}@ args:
let
  # variables
  python = python314;
  config-keys = callPackage ../config-keys args;

  # uv2nix glue code :
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = self + "tools/os"; };
  overlay = workspace.mkPyprojectOverlay { sourcePreference = "wheel"; };
  pythonSets = (callPackage pyproject-nix.build.packages { inherit python; }).overrideScope (
    lib.composeManyExtensions [
      pyproject-build-systems.overlays.wheel
      overlay
    ]
  );


  os-unwrapped = (callPackages pyproject-nix.build.util { }).mkApplication {
    venv = pythonSets.mkVirtualEnv "ostool-env" (workspace.deps.default);
    package = pythonSets.ostool;
  };
  # Todo : add the aliases "os-install" == "os install" (and same for update)
in symlinkJoin {
  name = "ostool";
  paths = [ os-unwrapped config-keys];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/os \
      --set-default OS_CONFIG_KEYS ${config-keys}${config-keys.destination}
  '';
  meta = {
    mainProgram = "$out/bin/os";
    licence = lib.licenses.mit;
  };
}
