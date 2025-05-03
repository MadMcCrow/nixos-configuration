{ python, ... }:
with python.pkgs;
buildPythonApplication {
  pname = "termcolors";
  version = "0.1.0";
  pyproject = true;
  nativeBuildInputs = [ poetry-core ];
  src = ./.;
}
