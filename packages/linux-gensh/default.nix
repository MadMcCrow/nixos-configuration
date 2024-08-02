{ python311Packages, ... }:
with python311Packages;
buildPythonApplication {
  pname = "linux-gensh";
  version = "1.0";
  buildInputs = [ ];
  src = ./.;
}
