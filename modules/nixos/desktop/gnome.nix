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

    caffeine # prevents lockscreen
    valent # replacement for GSConnect built with modern GTK
    quick-settings-tweaker # Gnome43+ quick settings editor
  
   

    appindicator # add systray icon support
    runcat # the best gnome extension
    wireless-hid # battery left in mouse/gamepad etc...
    pano  # clipboard manager

    alttab-mod # improve alt-tabbing

    
    tiling-assistant # Windows-like tiling update

    #
    material-shell

    # dash2dock-lite #buggy with read only filesystems
    dash-to-dock # turn the dash into a dock, always visible
    # dash-to-panel # might actually be more useful in 16:9

    openweather

    # hot-edge # hot edge for bottom corner

    rocketbar # some dashbar in topbar
    space-bar # Activity replaced by workspaces in topbar

    ofp-overview-feature-pack # customise overview -> do not work with gnome 44
    just-perfection # customise everything

    blur-my-shell # some nice blur effect

    gtk4-desktop-icons-ng-ding # add desktop icons

    #arcmenu # windows like start menu
    #weather-or-not # weather on the top top-bar but buggy : double image
    #forge     # tiling manager # kinda buggy
    #advanced-alttab-window-switcher # completely replace alt-tab
  ];

  # default gnome extensions
  # remove unless added
  defaultExtensions = with pkgs.gnomeExtensions; [
    launch-new-instance
    native-window-placement
    places-status-indicator
    auto-move-windows
    applications-menu
    window-list
    windownavigator
    workspace-indicator
  ];

  defaultApplications = with pkgs; [
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
  ];

  # some nice themes
  themes = with pkgs; [ adw-gtk3 ];

  systemPackages = [ pkgs.dconf pkgs.dconf2nix ]
    ++ (if cfg.extraApps then extraApps else [ ])
    ++ (if cfg.superExtraApps then superExtraApps else [ ])
    ++ (if cfg.extraExtensions then extraExtensions else [ ])
    ++ (if cfg.themes then themes else [ ])
    ++ (if cfg.gsconnect then [ pkgs.valent ] else []);

  # helper functions
  mkEnableOptionDefault = desc: default: mkEnableOption desc // {
      inherit default;
    };

  unwantedPackages = filter (x: !(elem x systemPackages))
  (defaultApplications ++ defaultExtensions);

in {

  # interface
  options.nixos.desktop.gnome = {
    # do you want gnome Desktop environment
    enable =
      mkEnableOptionDefault "gnome, the default desktop environment" false;
    # wayland support
    wayland =
      mkEnableOptionDefault "Wayland, the new standard meant to replace Xorg"
      true;
    # useful gnome apps
    extraApps = mkEnableOptionDefault "(useful) curated gnome apps" true;
    # useful gnome apps
    superExtraApps =
      mkEnableOptionDefault "curated gnome apps that are fun but not useful"
      false;
    # useful gnome extension
    extraExtensions = mkEnableOptionDefault "curated gnome extensions" true;
    # theming
    themes = mkEnableOptionDefault "gnome/gtk themes" true;
    # gnome online accounts sync
    onlineAccounts = mkEnableOptionDefault
      "online accounts for nextcloud/freecloud/google/ms-exchange" true;
    # gsconnect is KDE connect for gnome
    gsconnect = mkEnableOptionDefault "gsconnect, KDE connect for gnome" true;
  };

  # base config for gnome
  config = lib.mkIf (dsk.enable && cfg.enable) {

    system.nixos.tags = [ "Gnome" ];
    services.xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ] ++ unwantedPackages;
      desktopManager.xterm.enable = false;
      desktopManager.gnome.enable = true;
      # use gdm :
      displayManager.gdm = {
        enable = true;
        wayland = cfg.wayland;
      };

    };
    programs.xwayland.enable = cfg.wayland;

    # Remove default gnome apps unless explicitly requested
    environment.gnome.excludePackages = unwantedPackages;

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

    # enable DConf to edit gnome configuration
    programs.dconf.enable = true;
    # basically gnome keyring UI
    programs.seahorse.enable = true;
    # KDE Connect is not required anymore for GSconnect to work
    programs.kdeconnect = {
      enable = cfg.onlineAccounts;
      package = pkgs.valent;
    };
    # evolution is the email/contact/etc client for gnome
    programs.evolution.enable = false;

    # packages
    environment.systemPackages = systemPackages;

    # enable gnome settings daemon
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };
}
