{ python311Packages, ... }:
python311Packages.buildPythonApplication {
  pname = "darwin-rebuild";
  version = "1.0";
  propagatedBuildInputs = [ ];
  src = ./.;
}
