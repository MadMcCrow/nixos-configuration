# gtk.nix
# 	unique configuration for all gtk themes
{ config, pkgs, lib, ... }:
with builtins;
let
  dsk = config.nixos.desktop;
  cfg = dsk.gtk;

  # sadly with GTK4, everything is libadwaita.
  # GTK themes :
  gtkThemes = {
    # adwaita for gtk3
    adwaita = {
      name = "adwaita";
      package = pkgs.adw-gtk3;
    };
    # KDE breeze for gtk apps
    breeze-gtk = {
      name = "breeze-dark";
      package = pkgs.libsForQt5.breeze-gtk;
    };
    # cool looking themes
    orchis = {
      name = "Orchis";
      package = pkgs.orchis-theme;
    };
    marwaita = {
      name = "marwaita";
      package = pkgs.marwaita;
    };
    adementary = {
      name = "adementary";
      package = pkgs.adementary-theme;
    };
    numix = {
      name = "numix";
      package = pkgs.numix-gtk-theme;
    };
    stilo = {
      name = "stilo";
      package = pkgs.stilo-themes;
    };
  };


  # cool themes :
  # icons :
  iconThemes = with pkgs; {
    # KDE theme icons
    breeze-icons = {
      name = "Breeze";
      package = libsForQt5.breeze-icons;
    };
    # gnome theme icons
    adwaita = {
      name = "Adwaita";
      package = gnome.adwaita-icon-theme;
    };
    # other cool themes :
    kora = {
      name = "Kora";
      package = kora-icon-theme;
    };
    tela = {
      name = "Tela";
      package = tela-icon-theme;
    };
    telaCircle = {
      name = "Tela-Circle";
      package = tela-circle-icon-theme;
    };
    nordzy = {
      name = "nordzy";
      package = nordzy-icon-theme;
    };
    papirus = {
      name = "papirus";
      package = papirus-icon-theme;
    };
    numix = {
      name = "numix";
      package = numix-icon-theme;
    };
    numix-cursor = {
      name = "numix-cursor";
      package = numix-cursor-theme;
    };
  };

  optList = cond: l: if cond then l else [ ];
  allOf = name: set:
    map (x: getAttr name x) (filter (x: hasAttr name x) (attrValues set));


  # default themes
  defaultTheme = gtkThemes.orchis;
  defaultIcons = iconThemes.kora;
  defaultCursor = iconThemes.adwaita;

  mkThemeOption = name: default: {
    name = lib.mkOption {
      description = "the name of the ${name} theme to use";
      type = lib.types.str;
      default = default.name;
    };
    package = lib.mkOption {
      description = "the package for the ${name} theme to use";
      type = lib.types.package;
      default = default.package;
    };
  };

in {
  # set the gtk theme to use.
  # this allows referencing it everywhere
  options.nixos.desktop.gtk = {
    theme = mkThemeOption "gtk" defaultTheme;
    iconTheme = mkThemeOption "icon" defaultIcons;
    cursorTheme = mkThemeOption "cursor" defaultCursor;
    installAll = lib.mkEnableOption "all themes";
    # extra themes to install :
    # TODO:
    extra = {
      iconThemes = listToAttrs (map (x: {
        name = x.name;
        value = lib.mkEnableOption "${x.name}";
      }) (attrValues iconThemes));
      gtkThemes = listToAttrs (map (x: {
        name = x.name;
        value = lib.mkEnableOption "${x.name}";
      }) (attrValues gtkThemes));
    };
  };

  config = lib.mkIf dsk.enable {
    environment.systemPackages = lib.lists.unique ([
      cfg.theme.package
      cfg.iconTheme.package
      cfg.cursorTheme.package
    ]
    # all of them :
      ++ (optList cfg.installAll
        ((allOf "package" gtkThemes) ++ (allOf "package" iconThemes)))
      # those selected
      ++ (map (x : x.package) ( filter (x: cfg.extra.iconThemes."${x.name}") (attrValues iconThemes)))
      ++ (map (x : x.package) ( filter (x: cfg.extra.gtkThemes."${x.name}") (attrValues gtkThemes)))
    );
  };
}
