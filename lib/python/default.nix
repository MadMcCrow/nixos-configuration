# default.nix
# import all our python libs into an attribute set
args :
{
  mkPythonPackage = ./mkPythonPackage.nix;
}
