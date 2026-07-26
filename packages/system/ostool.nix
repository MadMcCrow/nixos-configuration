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
  deadnix,
  nixfmt,
  alejandra,
  nixos-install,
  nixos-install-tools,
  npins,
  ...
}@args:
with builtins;
let
  # template config for installation
  config = self + "/hosts/template/template.nix";

  nixdeps = [
    # update machine pins
    npins
    # gen the config and install
    nixos-install
    nixos-install-tools
    # format the config
    deadnix
    alejandra
    nixfmt
  ];

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

  os-unwrapped = (callPackages pyproject-nix.build.util { }).mkApplication {
    venv = pythonSets.mkVirtualEnv "ostool-env" workspace.deps.default;
    package = pythonSets.ostool;
  };

  # adding some "checks" to verify this function exist would be greate
  nonFunc = "mkSystem";
  # Todo : add the aliases "os-install" == "os install" (and same for update)
  #
  nixrev = (fromJSON (readFile self + "./flake.lock")).nodes.nixpkgs.locked.rev;
in
symlinkJoin {
  name = "ostool";
  version = "0.0"; # nonlib.version;
  paths = [
    os-unwrapped
  ]
  ++ nixdeps;
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/os \
      --set-default TEMPLATE_CONFIG ${config} \
      --set-default NIXPKGS_TAG  ${nixrev} \
      --prefix PATH : ${lib.makeBinPath nixdeps}
  '';
  meta = {
    mainProgram = "os";
    licence = lib.licenses.mit;
  };
}
