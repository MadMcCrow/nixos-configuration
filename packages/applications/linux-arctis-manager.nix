# Linux-Arctis-Manager
# a cool app to manage Steelseries headsets
{
  lib,
  pkgs,
  fetchFromGitHub,
  ...
}@ args:
let
  pythonPkgs = pkgs.python311Packages;
  version = "2.3.1";
  description = "A replacement for SteelSeries GG software, to manage your Arctis device on Linux!";
  name = "Linux-Arctis-Manager";
  owner = "elegos";
in
pythonPkgs.buildPythonPackage {
  pname = lib.toLower name;
  inherit version;

  src = fetchFromGitHub {
    inherit owner;
    repo ="${name}";
    rev = "v${version}";
    hash = "sha256-eeh2cUOLuezPKI+QdaYMgthaBOv/ccSoBEFJ50LZ59c=";
  };

  pyproject = true;
  build-system = [ pythonPkgs.uv-build ];
  propagatedBuildInputs = with pythonPkgs; [ uv uv-build autoflake ];

  meta = {
    homepage = "https://github.com/${owner}/${name}";
    inherit description;
    license = lib.licenses.gpl3;
  };
}
