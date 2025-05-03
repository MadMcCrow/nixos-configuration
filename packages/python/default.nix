# python/default.nix
/**
  add all of our python packages
*/
{
  python311,
  callPackage,
  lib,
  ...
}:
let
  # select python version :
  python = python311;
  # helper lambda :
  buildPoetryPython = callPackage ./buildpoetry.nix { inherit python; };
in
# list packages :
rec {
  # pycall :
  pycall = buildPoetryPython {
    pname = "pycall";
    version = "0.1.0";
    src = ./pycall;
  };
  # pyconfig
  nixos-pyconfig = buildPoetryPython {
    pname = "nixos-pyconfig";
    version = "0.1.0";
    src = ./nixos-pyconfig;
    pydeps = [ pycall python.pkgs.tqdm ];
    # meta.mainProgram = "nixos-pyconfig";
  };
  # pyinstaller
  nixos-pyinstall = buildPoetryPython {
    pname = "nixos-pyinstall";
    version = "0.1";
    pyproject = true;
    pydeps = [
      pycall
      nixos-pyconfig
    ];
    src = ./nixos-pyinstall;
  };

}
