# core/root.nix
# 	keep some root user settings
{ pkgs, config, lib, ... }:
with lib;
{
  # import thanks to specialArgs
  imports = [ impermanence.nixosModules.impermanence ];
 
  # lets keep root git config
  environment.persistence."/nix/persist/git" = {
      files = ["/root/.gitconfig"];
    };
}
