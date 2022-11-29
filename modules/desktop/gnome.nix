# gnome.nix
# 	Nixos Gnome Desktop environment settings
#	todo : implement Dconf2nix (possibly in a separate module)
{ config, pkgs, lib, ... }:
with builtins;
with lib;
let
  cfg = config.gnome;

  # extra gnome apps
  extraApps = with pkgs.gnome; [
    gnome-notes # simple note app
    gnome-todo # quick todo app
    gnome-tweaks # Gnome tweaks
    gnome-boxes # remote or virtual systems
    gnome-weather # get weather infos
    gnome-calendar # the calendar app
    gnome-logs # systemd logs
  ];

  # apps that you will not need
  superExtraApps = with pkgs; [
    baobab # disk usage analyzer
    gitg # git GUI client
    gnome-usage # cpu/gpu/mem usage monitor
    deja-dup # a backup tool
    gnome-keysign # GnuPG app
    drawing # a Paint-like app
  ];

  ## other potential candidates are :
  ## gnome.gnome-documents # manages documents collection(broken)
  ## commit # a nice commit editor (not in nixpkgs)

  # extra gnome extensions
  ## you will need to enable them in the gnome extension app
  extraExtensions = with pkgs.gnomeExtensions; [
    runcat # the best gnome extension
    dash-to-dock # turn the dash into a dock, always visible
    caffeine # prevents lockscreen
    appindicator # add systray icon support
    gsconnect # KDE Connect in the top-bar
    quick-settings-tweaker # Gnome43 quick settings editor
    tiling-assistant # Windows-like tiling update
    blur-my-shell # some nice blur effect
  ];

in {

  # interface
  options.gnome = {
    # do you want gnome Desktop environment
    enable = lib.mkOption {
      type = types.bool;
      default = true;
      description = "enable gnome Desktop environment";
    };

    wayland = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Wayland is the new standard meant to replace Xorg";
    };

    # useful gnome apps
    extraApps = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Some (useful) curated gnome apps";
    };

    # useful gnome apps
    superExtraApps = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Some curated gnome apps that are fun but not useful";
    };

    # useful gnome extension
    extraExtensions = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Some (useful) curated gnome extensions";
    };

    # gnome online accounts sync
    onlineAccounts = lib.mkOption {
      type = types.bool;
      default = true;
      description =
        "use online accounts for nextcloud/freecloud/google/ms-exchange";
    };

    # gsconnect is KDE connect for gnome
    gSConnect = lib.mkOption {
      type = types.bool;
      default = true;
      description = "gsconnect is KDE connect for gnome";
    };
  };

  # base config for gnome 
  config = lib.mkIf cfg.enable {

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

    # replace xterm by gnome terminal
    #nixpkgs.config.packageOverrides = pkgs: {
    #  system-path =
    #    pkgs.system-path.override { xterm = pkgs.gnome.gnome-terminal; };
    #};

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
    # programs.kdeconnect.enable = cfg.onlineAccounts;
    # evolution is the email/contact/etc client for gnome
    programs.evolution.enable = false;

    # packages
    environment.systemPackages = [ pkgs.dconf pkgs.dconf2nix ]
      ++ (if cfg.extraApps then extraApps else [ ])
      ++ (if cfg.superExtraApps then superExtraApps else [ ])
      ++ (if cfg.extraExtensions then extraExtensions else [ ]);

    # enable gnome settings daemon
    services.udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };
}
