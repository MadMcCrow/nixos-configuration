# enable lldap server
# lldap.nix
_: {
  services.lldap = {
    enable = true;
  };
}
