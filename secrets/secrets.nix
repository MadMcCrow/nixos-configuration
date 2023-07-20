# secrets/secrets.nix
# 	nix file for generating age secrets with agenix
#   not used in actual config
let
  nixNUC = builtins.readFile ./nixNUC.pub;
  nixAF  = builtins.readFile ./nixAF.pub;
in
{
  # No need for secrets here :
  "nextcloud.age".publicKeys    = [ nixNUC ];
  "postgresql.age".publicKeys   = [ nixNUC ];
}
