# flake part module for apps
{ withSystem, inputs, ... }: {
  perSystem = { pkgs, lib, system, ... }: {
    apps =
       with lib;
       mapAttrs' (
         n: v:
         nameValuePair ("os-" + n) {
           type = "app";
           program = value;
         }
       ) (pkgs.callPackages ../ostool inputs);
    };
}