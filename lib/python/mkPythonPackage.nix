# mkPythonPackage.nix
# helper function to make python packages with uv2nix
{
  lib,
  pkgs,
  pyproject-nix,
  uv2nix,
  pyproject-build-systems,
  self,
  ...
}:
name:
let
  python = pkgs.python312;
  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = self + "/packages/${name}/"; };
  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  pythonSets =
    (
      pkgs.callPackage pyproject-nix.build.packages {
        inherit python;
      }
      # necessary override for MacOS : https://pyproject-nix.github.io/uv2nix/platform-quirks.html
      // (with pkgs.stdenv; (lib.optionalAttrs isDarwin {
        stdenv = override {
          targetPlatform = targetPlatform // {
            darwinSdkVersion = "15.1";
          };
        };
      }))

    ).overrideScope
      (
        lib.composeManyExtensions [
          pyproject-build-systems.overlays.wheel
          overlay
        ]
      );
  inherit (pkgs.callPackages pyproject-nix.build.util { }) mkApplication;
in
mkApplication {
  venv = pythonSets.mkVirtualEnv "${name}-env" workspace.deps.default;
  package = pythonSets.${name};
}
