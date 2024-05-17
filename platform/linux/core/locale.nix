# linux/kernel.nix
# locale options for nixos
{ config, lib, ... }:
let
# glibc locales
us-utf8 = "en_US.UTF-8";
fr-utf8 = "fr_FR.UTF-8";
c-utf8  = "C.UTF-8";
in
{
  config = {

    # language formats :
    i18n = {
      defaultLocale = us-utf8;
      #supportedLocales = [
      #  us-utf8
      #  fr-utf8
      #  c-utf8
      #];
      # set all the variable
      extraLocaleSettings = {
        # LC_ALL   = us-utf8;
        # LANGUAGE = us-utf8;
        LC_TIME  = fr-utf8; # use a reasonable date format
      };
    };

    # time zone stuff :
    time.timeZone = "Europe/Paris";
    services.timesyncd.servers = [ "fr.pool.ntp.org" "europe.pool.ntp.org" ];
    location.provider = "geoclue2";

    # keyboard settings :
    services.xserver.xkb = {
      layout = "us";
      variant = "intl";
      options = "eurosign:e";
    };

    # font and use of keyboard options from the xserver
    console.font = "Lat2-Terminus16";
    console.useXkbConfig = true; # use xkbOptions in tty.

  };
}
