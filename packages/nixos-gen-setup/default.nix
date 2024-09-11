{ python311Packages, ... }:
with python311Packages;
buildPythonApplication {
  pname = "nixos-gen-setup";
  version = "1.0";
  buildInputs = [ ];
  src = ./.;
}
