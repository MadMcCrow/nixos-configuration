# secrets/secrets.nix
# 	nix file for generating age secrets with agenix
#   not used in actual config
#   TODO : use pub files instead of copying
let
  nextcloud = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDbznLZ5Z75GoVV5g6VrF75slMwmCRIJz6j7wqjZKgBN";
in 
{ 
  "nextcloud.age".publicKeys = [ nextcloud ]; 
}
