# system.nix
# define the update process in NonOS
nonOS:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  os = nonOS.mod "" config;
in
{
  options = os.mkOptions {
    # rename the OS
    customise = mkEnableOption "customise nixOS to ${nonOS.name}" // {
      default = true;
    };
  };

  config = os.mkConfig {
    environment = {
      etc."os-release".text = with nonOS.meta; ''
        NAME="${name}"
        PRETTY_NAME="${name}"
        VERSION_ID="${version}"
        VERSION="${version}-${status}"
        ID=nixos
        BUILD_ID="rolling"
        ANSI_COLOR="1;32"
        HOME_URL="${flake_url}"
        SUPPORT_URL="${flake_url}"
        BUG_REPORT_URL="${flake_url}/issues"
      '';

      systemPackages = [ os.pkgs.ostool ];
      defaultPackages = with pkgs; [
        openssl
        dnsutils
        nmap
      ];
    };

    hardware = {
      # we could include both microcodes
      # but the hardware detection can give you the correct param
      # cpu.amd.updateMicrocode = true;
      # cpu.intel.updateMicrocode = true;
      # we just need this to be enabled :
      enableRedistributableFirmware = true;
      firmware = [ pkgs.linux-firmware ];
    };

    programs = {
      # zsh is the far superior shell in my opinion
      zsh.enable = true;
      bash.enable = false;
    };

    services = {
      openssh = {
        enable = true;
        ports = [ 8323 ];
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          AllowUsers = attrNames config.users.users;
        };
      };
    };

    system = with nonOS.meta; {
      # let the user specify the state version themselves
      # but forgetting defining it shouldn't matter
      stateVersion = "26.05";
      # We customise the
      nixos.label = "${name}";
      nixos.variantName = "${name}";
    };

    time = {
      # we default to Paris
      timeZone = "Europe/Paris";
    };

    users = {
      defaultUserShell = pkgs.zsh;
      # enable mutable users if no user is set to admin
      mutableUsers = !(any (u: u.group == "wheel" || (any (g: g == "wheel") u.extraGroups)) (attrValues config.users.users));
    };
  };
}
