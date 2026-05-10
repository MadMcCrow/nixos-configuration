# waydroid.nix
# Support for android tv through waydroid with near native performance
{
  pkgs,
  lib,
  config,
  ...
}:
let
  # defined once
  package = pkgs.waydroid;
  # command to factory reset the android container
  waydroid-reset = pkgs.writeShellApplication {
    name = "waydroid-reset";
    runtimeInputs = [ package ];
    text = ''
      rm -rf ~/.local/share/waydroid
      rm -rf /var/lib/waydroid/overlay*
      sudo ${lib.getExe package} init -f
    '';
  };

  # Add GApps support
  # we don't need gapps for now, but this command would enable it
  waydroid-gapps = pkgs.writeShellApplication {
    text = ''
      sudo ${lib.getExe package} shell 'ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"'
    '';
  };

  # image downloaded from github
  androidtv-image = pkgs.stdenvNoCC.mkDerivation rec {
    pname = "androidtv";
    version = "20250327";
    src = pkgs.fetchFromGitHub {
      owner = "supechicken";
      repo = "waydroid-androidtv-build";
      rev = version;
      hash = "sha256-4peNKC5VHkmK2GphEsgslnXI7gtnhABL6Y1cc38mpzk=";
    };
    # copy vendor.img and system.img files to out
    installPhase = ''
      sudo mkdir -p $out
      sudo cp $src/*.img $out
    '';
  };

  waydroid-androidtv-install = pkgs.writeShellApplication {
    name = "waydroid-androidtv";
    runtimeInputs = [ androidtv-image ];
    text = ''
      sudo ${lib.getExe package} init -i ${androidtv-image}
    '';
  };
  # user for all the waydroid operation
  waydroidUser = "waydroid";

  # shortcut
  cfg = config.tv.waydroid;
in
{
  # interface
  options.tv.waydroid = with lib; {
    enable = mkEnableOption "waydroid-tv";
    autostart = mkEnableOption "auto start waydroid";
  };

  # implementation
  config = lib.mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
    # add our
    environment.systemPackages = [
      package
      waydroid-reset
      androidtv-image
      waydroid-androidtv-install
    ];

    # Custom services to start the whole waydroid ecosystem
    systemd.services = lib.mkIf cfg.autostart {
      "start-waydroid-container" = rec {
        enable = true;
        before = [ "waydroid-container.service" ];
        script = "${waydroid-androidtv-install}";
      };
      "start-waydroid-session" = rec {
        enable = true;
        after = [
          "waydroid-container.service"
          "start-waydroid-session.service"
        ];
        wantedBy = [ "graphical-session.target" ];
        script = "${lib.getExe package} session start";
      };
    };

    # user for cage/waydroid
    users.extraUsers."${waydroidUser}".isNormalUser = true;

    # start waydroid in full screen
    services = {
      xserver = lib.mkIf cfg.autostart {
        enable = true;
        displayManager = {
          autoLogin.user = waydroidUser;
          lightdm.greeter.enable = false;
        };
      };
      cage = {
        enable = true;
        user = waydroidUser;
        program = "${lib.getExe package} show-full-ui";
      };
      environment.systemPackages = [ waydroid-gapps ];
    };
  };
}
