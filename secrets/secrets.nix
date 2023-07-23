# secrets/secrets.nix
# 	nix file for generating age secrets with agenix
#   not used in actual config
let
  # define the files we need
  nixNUC = ./nixNUC.pub;
  nixAF  = ./nixAF.pub;
in
{
  # No need for secrets here :
  "nextcloud.age".publicKeys    = [ (builtins.readFile nixNUC) ];
  "postgresql.age".publicKeys   = [ (builtins.readFile nixNUC) ];
}
