# users/default.nix
# 	Each user is in a separate module
{ config, ... }: {
  # Users
  users.mutableUsers = false;
  # add user's module here
  imports = [ ./perard.nix ./guest.nix ];
}
