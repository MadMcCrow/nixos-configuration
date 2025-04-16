{ python311Packages, ... }:
with python311Packages;
buildPythonApplication {
  pname = "nixosgensetup";
  version = "1.0";
  buildInputs = [ ];
  src = ./.;
}
