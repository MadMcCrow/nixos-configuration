# core/update.nix
# 	creates a shell script to update the system
{ pkgs, config, lib, options, ... }:
with builtins;
with lib;
let
  updateScript = pkgs.writeShellScriptBin "autoUpdate" ''
    ${pkgs.git}/bin/git fetch --all
    ${pkgs.git}/bin/git checkout -B run
    ${pkgs.git}/bin/git rebase origin/main
    ${pkgs.nix}/bin/nix flake update --commit-lock-file
    ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake .# 
  '';
  cfg = config.services.autoUpdate;

  # update "program"
  update = stdenv.mkDerivation {
    name = "update";
    # Add the derivation to the PATH
    buildInputs = [ updateScript pkgs.git pkgs.nixos-rebuild ];
  };

in {
  options.services.autoUpdate = {
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
        How often to auto update
      '';
    };
  };

  config = with pkgs; {
    # update service
    systemd.services = mkIf cfg.enable {
      after = [ "multi-user.target" ];
      description = "updates the system to the latest possible version";
      startAt = "daily";
      serviceConfig = {
        Type = "oneshot";
        User = "root";
        ExecStart = "${update}/bin/update";
      };
    };
  };
}
