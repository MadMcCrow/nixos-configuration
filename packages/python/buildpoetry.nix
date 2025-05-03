# separate module to build application or packages with poetry
{pkgs,  python ? pkgs.python311, lib, ... }:
# lambda :
{
  src,
  pydeps ? [] ,
  ...
}@args:
with builtins;
with lib;
with python.pkgs;
let
  # recursively find the intersection of list of list
  recintersect = l: fold (xs: xss: intersectLists xss xs) (head l) (tail l);
  # list of dependencies for the build
  pydependencies = buildInputs ++ [ python.pkgs.poetry-core ];
in buildPythonPackage (
  # pydeps is not a standard input attr
  (removeAttrs args [
    "pydeps"
    "addBin"
  ])
  // rec {
    # reuse
    inherit src;
    # poetry need this :
    pyproject = true;

    buildInputs = pydeps ++ [ python.pkgs.poetry-core ];

    # help
    propagatedBuildInputs = pydeps;

    # meaningful meta 
    meta = (args.meta or { }) // {
      licences = [ licences.mit ];
      # allow use on all compatible platforms
      platforms = recintersect (map (x: x.meta.platforms) buildInputs);
    };
  }
)
