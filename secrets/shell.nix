# shell environment to use/develop with secrets
{ pkgs, pycnix, ... }:
let
  # pylib
  pylib = pycnix.lib."${pkgs.system}";
  # let pycnix use its python :
  #python = pycnix.python311;

  # pyage from pip :
  pyage = pylib.mkPipInstall {
    pname = "age";
    version = "0.5.1";
    sha256 = "sha256-pNnORcE6Eskef51vSUXRdzqe+Xj3q7GImAcRdmsHgC0=";
    libraries = [ "pynacl" "requests" "cryptography" "click" "bcrypt" ];
  };

  pycrypto = pylib.mkPipInstall {
    pname = "pycryptodome";
    version = "3.19.0";
    sha256 = "sha256-vDXUYyIs202+vTXgeEFVyB4WG5KE5Wfn6TPXIuUzMx4=";
    libraries = [ ];
  };

in pkgs.mkShell { buildInputs = [ pycrypto pyage ]; }
