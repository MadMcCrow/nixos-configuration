# gnome.nix
# 	Nixos Gnome Desktop environment settings
#	todo : implement Dconf2nix (possibly in a separate module)
#	todo : make an option for enabling gnome
{ config, pkgs, lib, ... }: {

  # enable GUI
  services.xserver = {
    enable = true;
    # remove xterm
    excludePackages = [ pkgs.xterm ];
    desktopManager.xterm.enable = false;
    # GDM :
    displayManager = {
      gdm = {
        enable = true;
        wayland = true; # Wayland
      };
    };
    # use Gnome
    desktopManager.gnome.enable = true;
  };
  programs.xwayland.enable = true;

  # replace xterm by gnome terminal
  nixpkgs.config.packageOverrides = pkgs: {
    system-path =
      pkgs.system-path.override { xterm = pkgs.gnome.gnome-terminal; };
  };

  # Gnome
  environment.gnome.excludePackages = with pkgs; [
    gnome.gnome-weather
    gnome-tour
    gnome-photos
    gnome.simple-scan
    gnome.gnome-music
    gnome.epiphany
    gnome.totem
    gnome.yelp
    gnome.cheese
    gnome.gnome-characters
    orca
  ];

  # disable unecessary services 
  services.gnome = {
    chrome-gnome-shell.enable = false;
    tracker-miners.enable = false;
    tracker.enable = false;
    gnome-online-miners.enable = lib.mkForce false;
    gnome-online-accounts.enable = lib.mkForce false;
    evolution-data-server.enable = lib.mkForce false;
    glib-networking.enable = true;
    gnome-keyring.enable = true;
    sushi.enable = true;
  };

  # enable DConf to edit gnome configuration
  programs.dconf.enable = true;
  programs.seahorse.enable = true;
  programs.kdeconnect.enable = true;
  programs.evolution.enable = false;

  environment.systemPackages = with pkgs; [
    dconf # configure gnome
    dconf2nix # export dconf in nix
    gnome.gnome-tweaks # Gnome tweaks
    gnomeExtensions.appindicator # systray icons
    gnomeExtensions.gsconnect # KDE Connect
  ];

  services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
}
