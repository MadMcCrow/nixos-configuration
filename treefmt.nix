# specify how to format the nonOS repository
{ pkgs, ... }:
{
  # Used to find the project root
  projectRootFile = "flake.nix";

  programs = {
    # all the nix formatter
    nixfmt.enable = false;
    statix.enable = true;
    deadnix = {
      enable = true;
      no-lambda-arg = false;
      no-lambda-pattern-names = true;
      no-underscore = true;
    };
    # python formatter
    ruff = {
      check = true;
      format = true;
    };
  };
}
