# desktop/kde.nix
# 	KDE FOR DESKTOP
{
  config,
  pkgs,
  pkgs-latest,
  lib,
  ...
}:
let
  # a plasmoid for start menu
  plasma-drawer =
    with pkgs;
    stdenv.mkDerivation rec {
      pname = "plasma-drawer";
      version = "1.4";
      src = fetchFromGitHub {
        owner = "p-connor";
        repo = pname;
        rev = "v${version}";
        hash = "sha256-oqEjClHupSJt5BE2i/qRZp1cEpf5vPfdR2qVYiX6gI0=";
      };
      nativeBuildInputs = [
        libsForQt5.kpackage
        libsForQt5.wrapQtAppsHook
        zip
      ];
      # installPhase = ''
      #   mkdir -p $out/share/plasma/plasmoids/plasma-drawer
      #   cd $src
      #   ${lib.getBin libsForQt5.kpackage}/bin/kpackagetool -i $out/share/plasma/plasmoids/plasma-drawer
      # '';
    };

  # KDE theme used by SteamOS
  vapor-theme = pkgs.stdenvNoCC.mkDerivation {
    name = "kde-vapor-theme";
    version = "0.16-1";
    nativeBuildInputs = with pkgs; [ zstd ];
    src = pkgs.fetchurl {
      url = "https://steamdeck-packages.steamos.cloud/archlinux-mirror/jupiter-rel/os/x86_64/steamdeck-kde-presets-0.16-1-any.pkg.tar.zst";
      hash = "sha256-3SOzqBUEPWLk7OIv5715whRJa3qmJaMXL1Gf/DKs5bU=";
    };
    unpackPhase = ''
      tar -xf  $src
    '';
    installPhase = ''
      mkdir -p $out/share
      cp -r ./usr/share/* $out/share/
    '';
  };
in
lib.mkIf config.nixos.desktop.enable {
  # set tag for version
  system.nixos.tags = [ "KDE" ];

  services.xserver = {
    enable = true;
    # SDDM :
    displayManager.sddm = {
      enable = true;
      enableHidpi = true;
      settings.General.DisplayServer = "x11-user";
    };
    # Enable Plasma 5 or 6
    desktopManager.plasma5 = {
      enable = true;
      useQtScaling = true;
      # default font with extra
      notoPackage = pkgs-latest.noto-fonts-lgc-plus;
    };
    # remove xterm
    services.xserver.desktopManager.xterm.enable = false;
    services.xserver.excludePackages = [ pkgs.xterm ];
  };

  # enable plasma
  qt.enable = true;
  qt.platformTheme = "kde";

  # enable tools
  programs = {
    dconf.enable = true;
    kdeconnect.enable = true;
    partition-manager.enable = true;
  };

  environment = {
    # remove useless KDE packages
    plasma5.excludePackages =
      with pkgs.libsForQt5;
      [
        oxygen
        khelpcenter
        plasma-browser-integration
        print-manager
        kio-extras
        khelpcenter
        kwallet
        kwallet-pam
        kate
        okular
      ]
      ++ (with pkgs.libsForQt5; [ kemoticons ]);

    # extra tools
    systemPackages = with pkgs; [
      dconf
      dconf2nix
      # theme
      lightly-boehs
      vapor-theme
      # icons
      papirus-icon-theme
      # plasmoid :
      # plasma-drawer
      # apps not installed from KDE :
      libsForQt5.kcalc
    ];
  };

}
