# Linux-Arctis-Manager
# a cool app to manage Steelseries headsets
{
  lib,
  python312Packages,
  fetchFromGitHub,
  ...
}@ args:
let
  pythonPkgs = python312Packages;
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
  };

  pyproject = true;
  build-system = [ pythonPkgs.uv-build ];
  propagatedBuildInputs = with pythonPkgs; [ uv autoflake ];

  meta = {
    homepage = "https://github.com/${owner}/${name}";
    inherit description;
    license = lib.licenses.gpl3;
  };
}
