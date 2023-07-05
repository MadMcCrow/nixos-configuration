# gnome.nix
# 	Nixos Gnome Desktop environment settings
#	TODO : implement Dconf2nix (possibly in a separate module)
# TODO : more curated/ personnal version of gnome 
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  dsk = config.nixos.desktop;
  cfg = dsk.gnome;
  fpk = dsk.flatpak.enable;

  # extra gnome apps
  extraApps = with pkgs.gnome;
    [
      gnome-notes # simple note app
      gnome-todo # quick todo app
      gnome-tweaks # Gnome tweaks
      gnome-boxes # remote or virtual systems
      gnome-weather # get weather infos
      gnome-calendar # the calendar app
      gnome-logs # systemd logs
    ] ++ (if fpk then [ pkgs.gnome.gnome-software ] else [ ]);

  # apps that you will not need
  superExtraApps = with pkgs; [
    baobab # disk usage analyzer
    gitg # git GUI client
    gnome-usage # cpu/gpu/mem usage monitor
    deja-dup # a backup tool
    gnome-keysign # GnuPG app
    drawing # a Paint-like app
    eyedropper # a color picker
  ];

  ## other potential candidates are :
  ## gnome.gnome-documents # manages documents collection(broken)
  ## commit # a nice commit editor (not in nixpkgs)

  # extra gnome extensions
  ## you will need to enable them in the gnome extension app
  extraExtensions = with pkgs.gnomeExtensions; [
    runcat # the best gnome extension
    caffeine # prevents lockscreen
    dash-to-dock # turn the dash into a dock, always visible
    quick-settings-tweaker # Gnome43+ quick settings editor
    appindicator # add systray icon support
    gsconnect # KDE Connect in the top-bar
    valent    # replacement for GSConnect built with modern GTK
    tiling-assistant # Windows-like tiling update
    blur-my-shell # some nice blur effect
    gtile # tile with grid
    unite # some ubuntu unity shell modification
    gtk4-desktop-icons-ng-ding # add desktop icons
    alttab-mod # improve alt-tabbing
    advanced-alttab-window-switcher # completely replace alt-tab
    unity-like-app-switcher # colourful alt-tab
    weather-or-not # weather on the top top-bar
    just-perfection # customise everything
    wireless-hid # battery left in mouse/gamepad etc...
  ];

  # some nice themes
  themes = with pkgs; [ zuki-themes theme-obsidian2 juno-theme ];

in {

  # interface
  options.nixos.desktop.gnome = {
    # do you want gnome Desktop environment
    enable = mkEnableOption (mdDoc "gnome, the default desktop environment");
    # wayland support
    wayland =
      mkEnableOption (mdDoc "Wayland, the new standard meant to replace Xorg")
      // {
        default = true;
      };
    # useful gnome apps
    extraApps = mkEnableOption (mdDoc "(useful) curated gnome apps") // {
      default = true;
    };
    # useful gnome apps
    superExtraApps =
      mkEnableOption (mdDoc "curated gnome apps that are fun but not useful");
    # useful gnome extension
    extraExtensions = mkEnableOption (mdDoc "curated gnome extensions") // {
      default = true;
    };
    # theming
    themes = mkEnableOption (mdDoc "gnome/gtk themes") // { default = true; };
    # gnome online accounts sync
    onlineAccounts = mkEnableOption
      (mdDoc "online accounts for nextcloud/freecloud/google/ms-exchange") // {
        default = true;
      };
    # gsconnect is KDE connect for gnome
    gSConnect = mkEnableOption (mdDoc "gsconnect, KDE connect for gnome") // {
      default = true;
    };
  };

  # base config for gnome 
  config = lib.mkIf (dsk.enable && cfg.enable) {

    system.nixos.tags = [ "Gnome" ];

    services.xserver = {
      # enable GUI
      enable = true;

      # remove xterm
      excludePackages = [ pkgs.xterm ];
      desktopManager.xterm.enable = false;

      # GDM :
      displayManager = {
        gdm = {
          enable = true;
          wayland = cfg.wayland; # Wayland
        };
      };
      # use Gnome
      desktopManager.gnome.enable = true;
    };
    programs.xwayland.enable = cfg.wayland;

    # Gnome useless apps :
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

    # gnome services :
    services.gnome = {
      # used for getting extensions from the web, prefer ExtensionManager or nixpkgs directly
      gnome-browser-connector.enable = false;
      tracker.enable = false; # trackers are indexation services for your files.
      tracker-miners.enable = false;
      gnome-online-miners.enable = lib.mkForce false;

      # online accounts
      gnome-online-accounts.enable =
        if cfg.onlineAccounts then lib.mkForce true else lib.mkForce false;
      evolution-data-server.enable =
        if cfg.onlineAccounts then lib.mkForce true else lib.mkForce false;

      # keep theses : they are useful
      glib-networking.enable = true; # GnuTLS and OpenSSL for gnome
      gnome-keyring.enable = true; # keyring stores gpg keys
      sushi.enable = true; # sushi is a preview/thumbnailer for nautilus

    };

    # enable DConf to edit gnome configuration (TODO : DConf2nix)
    programs.dconf.enable = true;
    # basically gnome keyring UI
    programs.seahorse.enable = true;
    # KDE Connect is not required anymore for GSconnect to work
    programs.kdeconnect = {
      enable = cfg.onlineAccounts;
      package = pkgs.gnomeExtensions.gsconnect;
    };
    # evolution is the email/contact/etc client for gnome
    programs.evolution.enable = false;

    # packages
    environment.systemPackages = [ pkgs.dconf pkgs.dconf2nix ]
      ++ (if cfg.extraApps then extraApps else [ ])
      ++ (if cfg.superExtraApps then superExtraApps else [ ])
      ++ (if cfg.extraExtensions then extraExtensions else [ ])
      ++ (if cfg.themes then themes else [ ]);

    # enable gnome settings daemon
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };
}
