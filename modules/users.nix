# users.nix
{ pkgs, nixpkgs, lib ... }:
{
  options.nonOS.users = with lib; mkOption {
    description = "List of users to create";
    type = types.submodule { # maybe add types.addCheck
         options = {
           fullname = mkOption {
             description = "Full name of the user as displayed in UI";
             type = types.emptyOr types.str;
             default = "";
           };
           shell = mkOption {
             description = "Shell to use for the user";
             type = addCheck types.str (shell: nixpkgs ? shell);
             default = "zsh";
           };
           groups = mkOption {
             description = "Groups the user belongs to";
             type = types.listOf types.str;
             default = [];
           };
           hashedPassword = mkOption {
             description = "Hashed password for the user";
             type = types.passwdEntry;
             default = "";
           };
         };
       };
       default = { };
  };

  config = {
    users = {
      defaultUserShell = pkgs.zsh;
      mutableUsers = false;
      users = mapAttrs (name: user: {
        name = name;
        fullname = user.fullname;
        shell = user.shell;
        groups = user.groups;
      }) config.nonOS.users;
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
