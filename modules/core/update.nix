# core/update.nix
# 	creates a shell script to update the system
{ pkgs, config, lib, ... }:
with builtins;
with lib;
let
  AutoUpdateScript = pkgs.writeShellScriptBin "autoUpdate"
  ''
  ${pkgs.git}/bin/git fetch --all
  ${pkgs.git}/bin/git checkout -B run
  ${pkgs.git}/bin/git rebase origin/main
  ${pkgs.nixos-rebuild}/bin/nixos-rebuild update flake --update-input nixpkgs --commit-lock-file
  ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .# 
  ''
  };
  cfg = config.services.autoUpdate;

in {
  stdenv.mkDerivation rec {
  name = "autoUpdate";
  # Add the derivation to the PATH
  buildInputs = [ AutoUpdateScript pkgs.git pkgs.nixos-rebuild ];
}

  options = {
    services.autoUpdate = { 
      enable = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to enable auto updates on the system.
        '';
      };
      timer = {
        type = types.str;
        default = "daily";
        description = ''
          How often to autoupdate
        '';
      #};
    };
  };

  systemd.services = mkIf cfg.enable {
      after = [ "multi-user.target" ];
      description = "updates the system to the latest possible version";
      startAt = "daily";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = ${pkgs.AutoUpdate}/bin/AutoUpdate';         
      };
   };
}
