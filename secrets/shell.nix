# shell environment to use/develop with secrets
{ pkgs ? import <nixpkgs> { } }:
let


  system = pkgs.system;
  python = pkgs.python310;

  pycnix = pkgs.fetchFromGitHub {
          owner = "MadMcCrow";
          repo = "pycnix";
          rev = "1b0ac9e7d758e3c30e5b46f043cbcdb6d13f72f3";
          sha256 = "";
        };

  pylib = {
    mkCythonBin = import "${pycnix}"/mkCythonBin.nix   pkgs   python;
    mkPipInstall = import "${pycnix}"/mkPipInstall.nix pkgs python;
  };

  # Demo : download a pip command and print all about it :
  gen-secret = let
    secrets = pkgs.writeText "secrets.py" (readFile ./secrets.py);
    pyage = pylib.mkPipInstall {
      name = "age";
      version = "0.5.1";
      sha256 = "sha256-pNnORcE6Eskef51vSUXRdzqe+Xj3q7GImAcRdmsHgC0=";
      libraries = ["pynacl" "requests" "cryptography" "click" "bcrypt"];
    };
  in
  pylib.mkCythonBin {
    name = "gen-secret";
    main = "secrets";
    modules = [ secrets ];
    libraries= [ pyage ]
  };
  

  cython-test = mkCythonBin {
    name = "test-cython";
    main = "test";
    modules = [ test ];
    libraries = [ pyage ];
  
  };
in pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  buildInputs = with pkgs.buildPackages; [
    pkgs.python310Full
    cython-test
    pyage
  ];
}