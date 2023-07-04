# darwin/default.nix
# 	Nix Darwin (MacOS) specific apps to use :
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let cfg = config.darwin;
in {
  config = mkIf cfg.enable {

    nix = {
      # nix settings
      settings = {
        substituters = [ "https://cache.nixos.org/" ];
        trusted-public-keys =
          [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
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
    services.nix-daemon.enable = true;

    programs.fish.interactiveShellInit = ''
      function __fish_command_not_found_handler --on-event="fish_command_not_found"
        ${
          if config.programs.fish.useBabelfish then ''
            command_not_found_handle $argv
          '' else ''
            ${pkgs.bashInteractive}/bin/bash -c \
              "source ${cfg.package}/etc/profile.d/command-not-found.sh; command_not_found_handle $argv"
          ''
        }
      end
    '';
  };
}
