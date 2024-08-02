# vendor/valve.nix
# support for valve hardware 
{ pkgs, lib, config, ... }:
let
  # shortcut :
  cfg = config.nixos.vendor.valve;
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
in {
  # interface :
  options.nixos.vendor.valve = with lib; {
    enable = mkEnableOption "valve hardware (steam controller, Vive, ...)";
  };

  config = lib.mkIf cfg.enable {
    hardware.steam-hardware.enable = true; # Steam udev rules
    # potentially problematic :
    environment.variables."LD_PRELOAD" = [ "${extest}/lib/libextest.so" ];
    environment.systemPackages = [ extest ];
    nixos.nix.unfreePackages = [ "steam-original" ];
  };
}
