{ stdenv, python311Packages, ... }:
stdenv.mkDerivation {
  #buildPythonApplication {
  pname = "linux-installer";
  version = "1.0";
  buildInputs = with python311Packages; [ sh rich ];
  src = ./.;
}
