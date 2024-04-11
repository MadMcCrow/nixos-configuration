# session.nix
# 	gnome kiosk session settings
{ pkgs, kioskApp, sessionName ? "kiosk" }:
let

  # helper to write TOML text
  mkTOML = class: attrs:
    let
      parseV = v:
        if builtins.isList v then
          builtins.concatStringsSep ";" (map (x: builtins.toString x) v)
        else if builtins.isBool v then
          (if v then "true" else "false")
        else
          builtins.toString v;
    in pkgs.lib.strings.concatLines ([ "[${class}]" ]
      ++ (map (x: builtins.concatStringsSep "=" [ x (parseV attrs."${x}") ])
        (builtins.attrNames attrs)));

  # to /usr/share/
  kiosk-shell-json = builtins.toJSON {
    "hasWindows" = true;
    "components" = [ "networkAgent" ];
    "panel" = {
      "left" = [ ];
      "center" = [ ];
      "right" = [ "a11y" "keyboard" "quickSettings" ];
    };
  };

  # desktop file for kiosk app
  kiosk-app-desktop = mkTOML "Desktop Entry" {
    Name = "kiosk-app";
    Exec = "${kioskApp}";
  };
  # Desktop file for session
  kiosk-desktop = mkTOML "Desktop Entry" rec {
    Name = "kiosk-shell";
    Exec = "${pkgs.gnome.gnome-session}/bin/gnome-session --session kiosk";
    TryExec = Exec;
    DesktopNames = "Kiosk";
    Type = "Application";
    X-GDM-SessionRegisters = true;
  };
  # Session fileapp
  kiosk-session = mkTOML "GNOME Session" {
    Name = "kiosk";
    RequiredComponents = [
      "kiosk-app"
      "kiosk.shell"
      "org.gnome.Shell"
      "org.gnome.SettingsDaemon.A11ySettings"
      "org.gnome.SettingsDaemon.Color"
      "org.gnome.SettingsDaemon.Datetime"
      "org.gnome.SettingsDaemon.Housekeeping"
      "org.gnome.SettingsDaemon.Keyboard"
      "org.gnome.SettingsDaemon.MediaKeys"
      "org.gnome.SettingsDaemon.Power"
      "org.gnome.SettingsDaemon.Rfkill"
      "org.gnome.SettingsDaemon.ScreensaverProxy"
      "org.gnome.SettingsDaemon.Sharing"
      "org.gnome.SettingsDaemon.Smartcard"
      "org.gnome.SettingsDaemon.Sound"
      "org.gnome.SettingsDaemon.UsbProtection"
      "org.gnome.SettingsDaemon.Wacom"
      "org.gnome.SettingsDaemon.XSettings"
    ];
  };

in pkgs.stdenvNoCC.mkDerivation rec {
  pname = sessionName;
  version = pkgs.gnome.gnome-session.version;

  # only do install :
  phases = [ "buildPhase" "installPhase" ];

  # this depends on having gnome shell and session
  buildInputs = with pkgs; [
    gnome.gnome-session
    gnome.gnome-shell
    gnome-desktop
  ];
  runtimeDependencies = buildInputs;

  passthru.providedSessions = [ sessionName ];

  buildPhase = ''
    echo ${
      pkgs.lib.strings.escapeShellArg kiosk-shell-json
    }    > ./${sessionName}.json
       echo ${
         pkgs.lib.strings.escapeShellArg kiosk-desktop
       } > ./${sessionName}.desktop
       echo ${
         pkgs.lib.strings.escapeShellArg kiosk-app-desktop
       }   > ./${sessionName}-app.desktop
       echo ${
         pkgs.lib.strings.escapeShellArg kiosk-session
       }       > ./${sessionName}.session
  '';

  installPhase = ''
    mkdir -p $out/share/gnome-shell/modes \
    $out/share/applications   \
    $out/share/gnome-sessions \
    $out/share/xsessions

    cp ./${sessionName}.json        $out/share/gnome-shell/modes
    cp ./${sessionName}-app.desktop $out/share/applications
    cp ./${sessionName}.desktop     $out/share/xsessions
    cp ./${sessionName}.session     $out/share/gnome-sessions/sessions
  '';
}
