{ python311Packages, ... }:
with python311Packages;
buildPythonApplication {
  pname = "termcolors";
  version = "1.0";
  buildInputs = [ ];
  src = ./.;
}
