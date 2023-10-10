# age-secret.nix
# package age-secret.py
{ pkgs, pycnix, name ? "age-gen-secret" }:
with builtins;
let
  # pylib
  pylib = pycnix.lib."${pkgs.system}";
  python = pkgs.python311;


  # pyage from pip :
  pyage = pylib.mkPipInstall {
    inherit python;
    pname = "age";
    version = "0.5.1";
    sha256 = "sha256-pNnORcE6Eskef51vSUXRdzqe+Xj3q7GImAcRdmsHgC0=";
    libraries = [ "pynacl" "requests" "cryptography" "click" "bcrypt" ];
  };

  pycrypto = pylib.mkPipInstall {
    inherit python;
    pname = "pycryptodome";
    version = "3.19.0";
    sha256 = "sha256-vDXUYyIs202+vTXgeEFVyB4WG5KE5Wfn6TPXIuUzMx4=";
    libraries = [ ];
  };

  # secret file
  filename = "secret.py";
  secretspy = pkgs.writeText filename (readFile ./age-secret.py);


  # implementation
in pylib.mkCxFreezeBin {
  inherit python name;
  src = secretspy;
  main = "${secretspy}";
  modules = [ "Crypto" "age"];
  nativeBuildInputs = [pycrypto pyage];
}
