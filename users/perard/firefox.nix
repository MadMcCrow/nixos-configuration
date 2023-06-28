# firefox.nix
#   firefox web browser
{ pkgs }: 
let 
package = pkgs.firefox-devedition-bin;
supportedPlatforms = package.meta.platforms;
supported = builtins.elem pkgs.system supportedPlatforms;
in
{
  programs = pkgs.lib.mkIf supported {
    firefox = {
      enable = true;
      inherit package;
    };
  };
}
