# users.nix
{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.nonOS.users =
    with lib;
    mkOption {
      description = "List of users to create";
      type = types.attrsOf (
        types.submodule {
          options = {
            fullname = mkOption {
              description = "Full name of the user as displayed in UI";
              type = types.str;
              default = "";
            };
            shell = mkOption {
              description = "Shell to use for the user";
              type = with types; nullOr (addCheck str (s: pkgs ? "${s}"));
              default = "zsh";
            };
            groups = mkOption {
              description = "Groups the user belongs to";
              type = types.listOf types.str;
              default = [ ];
            };
            hashedPassword = mkOption {
              description = "Hashed password for the user";
              type = types.str;
              default = "";
            };
          };
        }
      );
      default = { };
    };

  config = {
    users = {
      defaultUserShell = pkgs.zsh;
      mutableUsers = false;
      users = builtins.mapAttrs (name: user: {
        inherit name;
        description = user.fullname;
        shell = pkgs."${user.shell}";
        extraGroups = user.groups;
        isNormalUser = true;
        inherit (user) hashedPassword;
      }) config.nonOS.users;
    };

    services.openssh = {
      enable = true;
      ports = [ 8323 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = builtins.attrNames config.users.users;
      };
    };
    programs.zsh.enable = true;
    environment.defaultPackages = with pkgs; [
      openssl
      dnsutils
      nmap
      libfido2
    ];
  };
}
