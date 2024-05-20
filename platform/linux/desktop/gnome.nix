# environments/gnome.nix
# 	Nixos Gnome Desktop environment settings
# TODO : more curated/ personnal version of gnome
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  # useful gnome apps
  # could add gnome.gnome-terminal
  gnomeApps = with pkgs.gnome;
    [
      gnome-control-center # settings app
      gnome-notes # simple note app
      gnome-tweaks # Gnome tweaks
      gnome-boxes # remote or virtual systems
      gnome-calendar # the calendar app
      gnome-logs # systemd logs
      gnome-calculator # a calculator for quick math
      gnome-music # a music player
      nautilus # file manager
      gnome-backgrounds # gnome collection of cool backgrounds
      gnome-shell-extensions # manage and control extensions
      seahorse # manage gpg keys
      file-roller # compression and decompression of files
      gnome-disk-utility # disk info tool
      gnome-system-monitor # self explainatory
    ] ++ (with pkgs; [
      loupe # replaces eog and gnome-photos
      dconf
      dconf2nix
      polkit_gnome
      gnome-console
      adw-gtk3
      endeavour # previously gnome-todo
      baobab # disk usage analyzer
      gitg # git GUI client
      gnome-usage # cpu/gpu/mem usage monitor
      deja-dup # a backup tool
      gnome-keysign # GnuPG app
      drawing # a Paint-like app
      eyedropper # a color picker
    ]) ++ (lib.lists.optional config.nixos.flatpak.enable
      pkgs.gnome.gnome-software);

  # good gnome extensions
  ## you will need to enable them in the gnome extension app
  gnomeExtensions = with pkgs.gnomeExtensions; [
    alttab-mod # improve alt-tabbing
    appindicator # add systray icon support
    blur-my-shell # some nice blur effect
    caffeine # prevents lockscreen
    dash-to-dock # turn the dash into a dock, always visible
    just-perfection # customise everything
    openweather # the good weather app
    quick-settings-tweaker # Gnome43+ quick settings editor
    rocketbar # some dashbar in topbar
    runcat # the best gnome extension
    space-bar # Activity replaced by workspaces in topbar
    tiling-assistant # Windows-like tiling help
    wireless-hid # battery left in mouse/gamepad etc...
    pano # clipboard manager
    valent # replacement for GSConnect built with modern GTK
    gtk4-desktop-icons-ng-ding # add desktop icons
  ];

  # useless default gnome crap to remove :
  gnomeUnused = with pkgs.gnomeExtensions;
    [
      auto-move-windows
      applications-menu
      launch-new-instance
      native-window-placement
      places-status-indicator
      window-list
      windownavigator
      workspace-indicator
    ] ++ (with pkgs; [
      gnome-tour
      gnome.simple-scan
      gnome.epiphany
      gnome.totem
      gnome.yelp
      gnome.cheese
      gnome.gnome-weather
      gnome.gnome-characters
      orca
    ]);

in {
  # base config for gnome
  config = lib.mkIf config.nixos.desktop.enable {

    # gdm has better integration with gnome
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.displayManager.gdm.wayland = true;

    services.xserver.desktopManager.gnome.enable = true;

    # Remove default gnome apps unless explicitly requested
    services.xserver.desktopManager.xterm.enable = false;
    services.xserver.excludePackages = gnomeUnused ++ [ pkgs.xterm ];
    environment.gnome.excludePackages = gnomeUnused;

    # make qt looks like gtk
    qt.style = "adwaita-dark";
    qt.platformTheme = "gnome";

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
      rygel.enable = true; # Rygel UPnP Mediaserver
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
      enable = lib.mkDefault (!pkgs.valent.meta.broken);
      package = lib.mkDefault pkgs.valent;
    };
    # evolution is the email/contact/etc client for gnome
    programs.evolution.enable = false;

    # packages
    environment.defaultPackages = gnomeApps ++ gnomeExtensions;

    # enable gnome settings daemon
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];

    system.nixos.tags = [ "Gnome" ];
  };
}
