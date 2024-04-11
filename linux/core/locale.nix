# linux/kernel.nix
# locale options for nixos
{ config, lib, ... }: {
  config = {
    i18n.defaultLocale = "en_US.UTF-8";
    console.font = "Lat2-Terminus16";
    console.useXkbConfig = true; # use xkbOptions in tty.
    time.timeZone = "Europe/Paris";
    services.timesyncd.servers = [ "fr.pool.ntp.org" "europe.pool.ntp.org" ];
    location.provider = "geoclue2";
    # keyboard settings :
    services.xserver.xkb = {
      layout = "us";
      variant = "intl";
      options = "eurosign:e";
    };
  };
}
