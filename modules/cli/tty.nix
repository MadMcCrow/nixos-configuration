# tty.nix
# custom module to have a "better" tty
{ pkgs, ... }:
{
  config = {
    kmscon = {
      enable = true;
      hwRender = true;
      fonts = [
        {
          name = "Source Code Pro";
          package = pkgs.source-code-pro;
        }
      ];
      extraOptions = "--term xterm-256color";
    };
  };
}
