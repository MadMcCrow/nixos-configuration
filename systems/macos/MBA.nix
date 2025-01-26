# Nix configuration of MacBook Air
{ pkgs, nix-rosetta-builder, ... }:
{

  #imports = [ nix-rosetta-builder.darwinModules.default ];

  config = {
    #nix.linux-builder.enable = true;
    # nix.linux-builder = {
    #    enable = true;
    #    systems = [ "x86_64-linux" ];
    #    package = pkgs.darwin.linux-builder-x86_64;
    # };
    system.stateVersion = 5;
  };

}
