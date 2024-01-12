# scripts.nix
# python scripts for secrets
{ pkgs, pycnix }:
with builtins;
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

  # scripts :
  src = ./python;
  # the list of scripts and modules :
  scriptModules = [ "colors" "pyage" "files" ];

in {

  # create the key for encryption and decryption
  keys = pylib.mkCxFreezeBin {
    inherit src;
    name = "nixage-keys";
    main = "nixage_keys.py";
    modules = [ "Crypto" "age" ] ++ scriptModules;
    nativeBuildInputs = [ pycrypto pyage ];
    meta = {
      licences = [ pkgs.lib.Licences.mit ];
      description = pkgs.lib.mdDoc
        "A tool to generate SSH-keys for secrets, written in python";
      mainProgram = "nixage-keys";
    };
  };

  # decrypt secret anywhere you want
  crypt = pylib.mkCxFreezeBin {
    inherit src;
    name = "nixage-crypt";
    main = "nixage_crypt.py";
    modules = [ "Crypto" "age" ] ++ scriptModules;
    nativeBuildInputs = [ pycrypto pyage ];
    meta = {
      licences = [ pkgs.lib.Licences.mit ];
      description = pkgs.lib.mdDoc
        "A tool to encrypt and decrypt age secrets, written in python";
      mainProgram = "nixage-crypt";
    };
  };
}
