# users.nix
{ pkgs, nixpkgs, ... }:
{
  options.nonOS.users = {
    useSSH = lib.mkEnableOption "Enable SSH access for users";
  };

  config = {
    users = {
      defaultUserShell = pkgs.zsh;
      mutableUsers = false;
    };

    services.openssh = {
      enable = true;
        ports = [ 8323 ];
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = lib. config.users.users;
        };
    };
    environment.defaultPackages =  with pkgs;
    [

          libfido2
          onlykey-cli
          onlykey-agent
    ];
  };
}
