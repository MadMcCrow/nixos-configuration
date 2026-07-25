# specify how to format the nonOS repository
{ pkgs, ... }: {
  # Used to find the project root
  # projectRootFile = "flake.nix";
  projectRootFile = "treefmt.nix";

  programs = {
    autocorrect.enable = true;
    # all the nix formatter
    nixfmt.enable = true;
    statix.enable = true;
    deadnix = {
      enable = false;
      no-lambda-arg = false;
      no-lambda-pattern-names = true;
      no-underscore = true;
    };
    alejandra.enable = true;
    # python formatter
    ruff-check.enable = true;
    ruff-format.enable = true;
    isort.enable = true;
    # shell formatter
    shellcheck.enable = true;
  };
}
