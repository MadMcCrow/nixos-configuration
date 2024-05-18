# linux specific ssh config
{ pkgs, ... }:
{
  # make sure the ssh config is stored on a persistent storage
  fileSystems."/etc/static/ssh" = {
      device = "/nix/persist/ssh";
      options = [ "bind" ];
  };

   # allow users to login via ssh
    security.pam.enableSSHAgentAuth = true;

    # remote shell :
    services.openssh = {
      enable = true;
      # require public key authentication for better security
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
      };
      #permitRootLogin = "yes";
    };

    # same GID for all SSH users
    users.groups.ssl-cert.gid = 119;

    environment.defaultPackages = [pkgs.openssl];
}
