# Auto-update darwin with a single command
{ pkgs, config, lib, nixpkgs, system, ... }:
let

  thisFlake = "github:MadMcCrow/nixos-configuration";
  # TODO : hostname from nix
  thisConfig = "darwinConfigurations.$(hostname -s).system";
  # a command that download the latest version from github
  # and build it
  # TODO :
  #   - clean output

  nixdarwin-rebuild = pkgs.writeShellApplication {
    name = "nixdarwin-rebuild";
    # runtimeInputs = with pkgs; [ nix ];
    text = ''
      nix build "${thisFlake}#${thisConfig}"
      RESULT=$?
      if [ $RESULT -eq 0 ]; then
        sudo ./result/sw/bin/darwin-rebuild switch --flake .#
        exit $?
      else
        echo "nix build failed"
        exit 1
      fi
    '';
  };
in { environment.systemPackages = [ nixdarwin-rebuild ]; }
