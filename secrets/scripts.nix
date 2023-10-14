# sripts.nix
# package pythopn scripts for secrets
{ pkgs, pycnix }:
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

  # scripts :
  src = ./python;

in {
  ageSecret = pylib.mkCxFreezeBin {
    inherit python src;
    name = "nixage-secret";
    main = "age_secret.py";
    modules = [ "Crypto" "age" "colors" "ssh_keygen" ];
    nativeBuildInputs = [ pycrypto pyage ];
  };

  sshKeygen = pylib.mkCxFreezeBin {
    inherit python src;
    name = "nixage-sshkeygen";
    main = "ssh_keygen.py";
    modules = [ "Crypto" "age" "colors" ];
    nativeBuildInputs = [ pycrypto pyage ];
  };
}
