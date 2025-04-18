{ python311Packages, ... }:
with python311Packages;
buildPythonApplication {
  pname = "termcolors";
  version = "0.1.0";
  pyproject = true;
  nativeBuildInputs = [ poetry-core ];
  src = ./.;
}
