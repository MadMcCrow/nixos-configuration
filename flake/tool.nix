# flake part module for ostool
{
  withSystem,
  inputs,
  ...
}:
{
  perSystem =
    {
      pkgs,
      lib,
      system,
      ...
    }:
    rec {
      # import os tool source
      packages.ostool = pkgs.callPackage ../ostool inputs;

      apps.os = {
        type = "app";
        program = packages.ostool;
      };
    };
}
