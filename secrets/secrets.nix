# secrets/secrets.nix
# 	nix file for generating age secrets with agenix
#   not used in actual config
#   TODO : use pub files instead of copying
let
  nextcloud = builtins.readFile ./nextcloud.pub;
in
{
  "nextcloud.age".publicKeys = [ nextcloud ];
}
