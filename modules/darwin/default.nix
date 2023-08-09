# darwin/default.nix
# 	Nix Darwin (MacOS) Specific settings
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # shortcuts :
  cfg = config.darwin;
  pam = cfg.security.pam.sudoTouchIdAuth;

  # only M1 supported for now
  isDarwin = pkgs.system == "aarch64-darwin";

  # helper functions
  mkEnableOptionDefault = desc : default: (mkEnableOption desc) // { inherit default;};

  # init for fish and "command not found"
  fishInit = if config.programs.fish.useBabelfish then ''
            command_not_found_handle $argv
          '' else ''
            ${pkgs.bashInteractive}/bin/bash -c \
              "source ${cfg.package}/etc/profile.d/command-not-found.sh; command_not_found_handle $argv"
          '';


  # We don't use `environment.etc` because this would require that the user manually delete
  # `/etc/pam.d/sudo` which seems unwise given that applying the nix-darwin configuration requires
  # sudo. We also can't use `system.patchs` since it only runs once, and so won't patch in the
  # changes again after OS updates (which remove modifications to this file).
  #
  # As such, we resort to line addition/deletion in place using `sed`. We add a comment to the
  # added line that includes the name of the option, to make it easier to identify the line that
  # should be deleted when the option is disabled.
  mkSudoTouchIdAuthScript = isEnabled:
    let
      file = "/etc/pam.d/sudo";
      option = "security.pam.enableSudoTouchIdAuth";
    in ''
      ${if isEnabled then ''
        # Enable sudo Touch ID authentication, if not already enabled
        if ! grep 'pam_tid.so' ${file} > /dev/null; then
          sed -i "" '2i\
        auth       sufficient     pam_tid.so # nix-darwin: ${option}
          ' ${file}
        fi
      '' else ''
        # Disable sudo Touch ID authentication, if added by nix-darwin
        if grep '${option}' ${file} > /dev/null; then
          sed -i "" '/${option}/d' ${file}
        fi
      ''}
    '';


in {

  # interface 
  options.darwin = mkIf isDarwin {
    # enable MacOS
    enable = mkEnableOptionDefault  "Darwin (MacOS)" true;
    # Touch ID with sudo :
    security.pam.sudoTouchIdAuth.enable = mkEnableOptionDefault ''
      sudo authentication with Touch ID
      When enabled, this option adds the following line to /etc/pam.d/sudo:
          auth       sufficient     pam_tid.so
      (Note that macOS resets this file when doing a system update. As such, sudo
      authentication with Touch ID won't work after a system update until the nix-darwin
      configuration is reapplied.)
    '' cfg.enable;
  };

  # implementation
  config = mkIf ( cfg.enable && isDarwin ) {
    # nix settings
    nix = {
      settings = {
        substituters = [ "https://cache.nixos.org/" ];
        trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
        trusted-users = [ "@admin" ];
      };

      # Enable experimental nix command and flakes
      # nix.package = pkgs.nixUnstable;
      extraOptions = ''
        auto-optimise-store = true
        experimental-features = nix-command flakes
      '' + lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';

    };

    # Create /etc/bashrc that loads the nix-darwin environment.
    programs.zsh.enable = true;

    # Auto upgrade nix package and the daemon service.
    # TODO : find new variable name
    #services.nix-daemon.enable = true;

    programs.fish.interactiveShellInit = ''
      function __fish_command_not_found_handler --on-event="fish_command_not_found"
        ${fishInit}
      end
    '';

    # PAM support
    system.activationScripts.extraActivation = mkIf pam.enable {
      text = ''
        # PAM settings
        echo >&2 "setting up pam..."
        ${mkSudoTouchIdAuthScript cfg.enable}
      '';
    };
  };
}
