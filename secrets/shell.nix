# shell environment to use/develop with secrets
{ pkgs ? import <nixpkgs> { }, pycnix, ... }:
with builtins;
let


  system = pkgs.system;
  python = pkgs.python310;

  # pycnix is obtained via flake
  /*
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
  */

  pylib = pycnix.lib."${pkgs.system}";

  pyage = pylib.mkPipInstall {
      name = "age";
      version = "0.5.1";
      sha256 = "sha256-pNnORcE6Eskef51vSUXRdzqe+Xj3q7GImAcRdmsHgC0=";
      libraries = ["pynacl" "requests" "cryptography" "click" "bcrypt"];
  };

  # gen secrets
  shell-age-secrets = let
    secretspy = pkgs.writeText "secrets.py" (readFile ./secrets.py);
  in
  pylib.mkCythonBin {
    name = "shell-age-secrets";
    main = "secrets";
    modules = [ secretspy ];
    libraries= [ pyage python.pycrypto ];
  };

in pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  buildInputs = with pkgs.buildPackages; [
    python
    shell-age-secrets
    pyage
  ];
}
