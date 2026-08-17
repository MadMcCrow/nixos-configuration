# flake part module for apps
{
  withSystem,
  inputs,
  ...
}:
{
  imports = [ inputs.git-hooks-nix.flakeModule ];
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    {
      pre-commit.settings.hooks = {
        nixpkgs-fmt.enable = true;

        update-flake = {
          enable = true;
          name = "update-packages";
          description = "Run MyTool on all files in the project";
          files = "\\.mtl$";
          entry = "${pkgs.my-tool}/bin/mytoolctl";
        };
      };
    };
}
