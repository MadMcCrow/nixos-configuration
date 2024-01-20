# environments/gnome.nix
# 	Nixos Gnome Desktop environment settings
# TODO : more curated/ personnal version of gnome
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  fpk = config.nixos.flatpak.enable;

  # useful gnome apps
  # could add gnome.gnome-terminal
  gnomeApps = (with pkgs; [ dconf dconf2nix polkit_gnome gnome-console ])
    ++ (with pkgs.gnome; [
      gnome-control-center # settings app
      gnome-notes # simple note app
      gnome-tweaks # Gnome tweaks
      gnome-boxes # remote or virtual systems
      gnome-calendar # the calendar app
      gnome-logs # systemd logs
      gnome-calculator # a calculator for quick math
      nautilus # file manager
      gnome-backgrounds # gnome collection of cool backgrounds
      gnome-shell-extensions # manage and control extensions
      seahorse # manage gpg keys
      file-roller # compression and decompression of files
      gnome-system-monitor # self explainatory
    ]) ++ (with pkgs; [
      endeavour # previously gnome-todo
      baobab # disk usage analyzer
      gitg # git GUI client
      gnome-usage # cpu/gpu/mem usage monitor
      deja-dup # a backup tool
      gnome-keysign # GnuPG app
      drawing # a Paint-like app
      eyedropper # a color picker
    ]) ++ (if fpk then [ pkgs.gnome.gnome-software ] else [ ]);

  # good gnome extensions
  ## you will need to enable them in the gnome extension app
  gnomeExtensions = with pkgs.gnomeExtensions; [
    caffeine # prevents lockscreen
    # valent # replacement for GSConnect built with modern GTK
    quick-settings-tweaker # Gnome43+ quick settings editor
    appindicator # add systray icon support
    runcat # the best gnome extension
    wireless-hid # battery left in mouse/gamepad etc...
    # pano # clipboard manager
    alttab-mod # improve alt-tabbing
    tiling-assistant # Windows-like tiling help
    dash-to-dock # turn the dash into a dock, always visible
    openweather # the good weather app
    rocketbar # some dashbar in topbar
    space-bar # Activity replaced by workspaces in topbar
    just-perfection # customise everything
    blur-my-shell # some nice blur effect
    gtk4-desktop-icons-ng-ding # add desktop icons
  ];

  # useless default gnome crap to remove :
  gnomeUnused = with pkgs.gnomeExtensions;
    [
      launch-new-instance
      native-window-placement
      places-status-indicator
      auto-move-windows
      applications-menu
      window-list
      windownavigator
      workspace-indicator
    ] ++ (with pkgs; [
      gnome-tour
      gnome-photos
      gnome.simple-scan
      gnome.gnome-music
      gnome.epiphany
      gnome.totem
      gnome.yelp
      gnome.cheese
      gnome.gnome-weather
      gnome.gnome-characters
      orca
    ]);

  # themes to unify gnome appearance
  themes = with pkgs; [ adw-gtk3 ];

  backgrounds = with pkgs; [
    # fondo
    variety
    # sunpaper
    # swww
    cinnamon.mint-artwork
    gnome.gnome-backgrounds
    deepin.deepin-wallpapers
    budgie.budgie-backgrounds
    adapta-backgrounds
  ];

in {
  # base config for gnome
  config = lib.mkIf config.nixos.desktop.enable {

    # gdm has better integration with gnome
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.gdm.wayland = true;

    services.xserver.desktopManager.gnome.enable = true;
    # Remove default gnome apps unless explicitly requested
    services.xserver.excludePackages = gnomeUnused;
    environment.gnome.excludePackages = gnomeUnused;

    # gnome services :
    services.gnome = {

      # disable useless shit.
      core-utilities.enable = false;
      # this makes for a smaller gnome, but components might not work :
      # core-shell.enable = lib.mkForce false;

      # used for getting extensions from the web, prefer ExtensionManager or nixpkgs directly
      gnome-browser-connector.enable = false;
      tracker.enable = false; # trackers are indexation services for your files.
      tracker-miners.enable = false;
      gnome-online-miners.enable = lib.mkForce false;

      # online accounts
      gnome-online-accounts.enable = true;
      evolution-data-server.enable = true;

      # keep theses : they are useful
      glib-networking.enable = true; # GnuTLS and OpenSSL for gnome
      gnome-keyring.enable = true; # keyring stores gpg keys
      sushi.enable = true; # sushi is a preview/thumbnailer for nautilus
    };

    # not necessary :
    xdg.portal.extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
      libportal-gtk4
    ];

    # enable DConf to edit gnome configuration
    programs.dconf.enable = true;

    programs.seahorse.enable = true;

    programs.kdeconnect = {
      enable = !pkgs.valent.meta.broken;
      package = pkgs.valent;
    };
    # evolution is the email/contact/etc client for gnome
    programs.evolution.enable = false;

    # packages
    environment.systemPackages = gnomeApps ++ gnomeExtensions ++ themes
      ++ backgrounds;

    # enable gnome settings daemon
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

    system.nixos.tags = [ "Gnome" ];
  };
}
