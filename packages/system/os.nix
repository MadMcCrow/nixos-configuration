# os/default.nix
# build the os tool
{
  self,
  lib,
  nonlib,
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
with builtins;
let
  # variables
  python = python314;
  config-keys = callPackage ./config-keys.nix args;

  # uv2nix glue code :
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = self + "/tools/os"; };
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

  # nonOS mkSystem name, as detected on outputs of flakes
  # this convoluted approach means building the tool fail if the method is renamed or not present
  nonFunc = elemAt (attrNames (lib.filterAttrs (n: v: n == "mkSystem") nonlib)) 0;

  # Todo : add the aliases "os-install" == "os install" (and same for update)
in symlinkJoin {
  name = "ostool";
  version = nonlib.version;
  paths = [ os-unwrapped config-keys];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/os \
      --set-default OS_CONFIG_KEYS ${config-keys}${config-keys.destination} \
      --set-default OS_FLAKE_PATH ${self} \
      --set-default OS_MAKE_SYSTEM "lib.${nonFunc}" \
      --set-default OS_BUILD_TEMP \$\{TMPDIR-/tmp\}/os-tool \
  '';
  meta = {
    mainProgram = "os";
    licence = lib.licenses.mit;
  };
}
