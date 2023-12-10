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
  scriptModules = [ "age_crypt" "apply_secret" "colors" "ssh_keygen" "files" ];

in {

  # create the key for encryption and decryption
  genKeys = pylib.mkCxFreezeBin {
    inherit src;
    name = "nixage-sshkeygen";
    main = "ssh_keygen.py";
    modules = [ "Crypto" "age" ] ++ scriptModules;
    nativeBuildInputs = [ pycrypto pyage ];
  };

  # create a secret for encryption
  genSecret = pylib.mkCxFreezeBin {
    inherit src;
    name = "nixage-create";
    main = "gen_secret.py";
    modules = [ "Crypto" "age" ] ++ scriptModules;
    nativeBuildInputs = [ pycrypto pyage ];
  };

  # decrypt secret anywhere you want
  applySecret = pylib.mkCxFreezeBin {
    inherit src;
    name = "nixage-apply";
    main = "apply_secret.py";
    modules = [ "Crypto" "age" ] ++ scriptModules;
    nativeBuildInputs = [ pycrypto pyage ];
  };
}
