# hardware/hid.nix
# support for logitech mouses
{ pkgs, lib, config, ... }:
let cfg = config.nixos.hid;
in {
  # interface :
  options.nixos.hid = with lib; {
    logitech.enable = mkEnableOption "logitech hardware";
    valve.enable =
      mkEnableOption "valve hardware (steam controller, Vive, ...)";
    xbox.enable = mkEnableOption "xbox hardware (controller, dongle, ...)";
  };

  # merge all options :
  config = with lib;
    mkMerge [
      # logitech config
      (mkIf cfg.logitech.enable {
        hardware.logitech = {
          wireless.enable = true;
          wireless.enableGraphical = false;
          lcd.startWhenNeeded = true;
        };
      })
      # Valve config :
      (let
        # Extest is a drop in replacement for the X11 XTEST extension. It creates a virtual device with the uinput kernel module.
        # It's been primarily developed for allowing the desktop functionality on the Steam Controller to work while Steam is open on Wayland.
        extest = pkgs.rustPlatform.buildRustPackage rec {
          pname = "extest";
          version = "1.0.2";
          src = pkgs.fetchFromGitHub {
            repo = "extest";
            owner = "Supreeeme";
            rev = version;
            hash = "sha256-qdTF4n3uhkl3WFT+7bAlwCjxBx3ggTN6i3WzFg+8Jrw=";
          };
          cargoLock.lockFile = "${src}/Cargo.lock";
          meta = {
            homepage = "https://github.com/Supreeeme/extest";
            license = lib.licenses.mit;
            platforms = lib.platforms.linux;
          };
        };
      in mkIf cfg.valve.enable {
        hardware.steam-hardware.enable = true; # Steam udev rules
        # potentially problematic :
        environment.variables."LD_PRELOAD" = [ "${extest}/lib/libextest.so" ];
        environment.systemPackages = [ extest ];
        nixos.nix.unfreePackages = [ "steam-original" ];
      })
      # xbox config
      (mkIf cfg.xbox.enable {
        hardware.xone.enable = true;
        nixos.nix.unfreePackages = [ "xow_dongle-firmware" ];
      })
    ];
}
