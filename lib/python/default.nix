# default.nix
# import all our python libs into an attribute set
_ : {
  mkPythonPackage = ./mkPythonPackage.nix;
}
