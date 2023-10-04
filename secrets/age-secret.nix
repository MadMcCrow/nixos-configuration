# age-secret.nix
# package age-secret.py
{ pkgs, pycnix, name ? "age-gen-secret" }:
with builtins;
let
  # pylib
  pylib = pycnix.lib."${pkgs.system}";

  # secret file
  secretspy = pkgs.writeText "secret.py" (readFile ./age-secret.py);

  # pyage from pip :
  pyage = pylib.mkPipInstall {
    name = "age";
    version = "0.5.1";
    sha256 = "sha256-pNnORcE6Eskef51vSUXRdzqe+Xj3q7GImAcRdmsHgC0=";
    libraries = [ "pynacl" "requests" "cryptography" "click" "bcrypt" ];
  };

  pycrypto = pylib.mkPipInstall {
    name = "pycryptodome";
    version = "3.19.0";
    sha256 = "sha256-vDXUYyIs202+vTXgeEFVyB4WG5KE5Wfn6TPXIuUzMx4=";
    libraries = [ ];
  };

  # implementation
in pylib.mkCythonBin {
  inherit name;
  version = "0.1";
  main = "secrets";
  modules = [ secretspy ];
  libraries = [ pyage pycrypto ];
}
