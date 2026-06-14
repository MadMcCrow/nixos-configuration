# lib/system/default.nix
# import all functions necessary to build systems
args :
{
  mkAppliance = import ./mkAppliance.nix args;
  mkSystem = import ./mkSystem.nix args;
}
