# core/security.nix
# some extra security options 
{ ... }: {
  # disable the sudo warning for users (they might otherwise see it constantly):
  security.sudo.extraConfig = "Defaults        lecture = never";
  security.apparmor.enable = false;
}
