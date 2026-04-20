# lib/systems/default.nix
# exposes functions to build systems
args :
{
  mkSystem = import ./mkSystem.nix args;
  mkApplication = import ./mkApplication.nix args;
}
