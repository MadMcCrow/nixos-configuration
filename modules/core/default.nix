# system.nix
# define the update process in NonOS
nonOS :
inputs@{
  config,
  lib,
  pkgs,
  ...
} :
with lib;
with nonOS;
let
  os = mod "" config;
in
{
  options = os.mkOptions {
    # rename the OS
    customise = mkEnableOption "customise nixOS to ${os.name}" // {
      default = true;
    };
  };

  config = os.mkConfig {

    environment = mkPrio {
      etc."os-release".text = ''
        NAME="${os.name}"
        PRETTY_NAME="${os.name}"
        VERSION_ID="${os.version}"
        VERSION="${os.version}-${os.status}"
        ID=nixos
        BUILD_ID="rolling"
        ANSI_COLOR="1;32"
        HOME_URL="${flake_url}"
        SUPPORT_URL="${flake_url}"
        BUG_REPORT_URL="${flake_url}/issues"
      '';

      systemPackages = [ nonpkgs.os ];
      defaultPackages =
        with pkgs;
        [
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
      zsh.enable = mkPrio true;
      bash.enable = mkPrio false;
    };

    services = {
      openssh = mkPrio {
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

    system = {
      # let the user specify the state version themselves
      # but forgetting defining it shouldn't matter
      stateVersion = mkDefault "26.05";
      # We customise the
      nixos.label = "${os.name}";
      nixos.variantName = "${os.name}";
    };

    time = {
      # we default to Paris
      timeZone = mkPrio "Europe/Paris";
    };

    users = {
      defaultUserShell = mkPrio pkgs.zsh;
      # enable mutable users if no user is set to admin
      mutableUsers = !(any (x: x.admin == true) (attrValues config.users.users));
    };
  };
}
