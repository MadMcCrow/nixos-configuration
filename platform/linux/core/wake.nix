# wake.nix
# options to auto-shutdown and wakeup with rtc-wake
{ lib, config, ... }:
let cfg = config.nixos.autowake;
in {
  # interface
  options.nixos.autowake = with lib; {
    enable = mkEnableOption "auto sleep/wake up timer";
    # timer options :
    time = let
      mkTimeOption = desc:
        mkOption {
          type = types.str; # TODO : use systemdUtils timers
          description = desc;
        };
    in {
      sleep = mkTimeOption "time to put to sleep";
      wakeup = mkTimeOption "time to wake up";
    };
  };

  # implementation :
  config = lib.mkIf cfg.enable {

    # make sure sleep is available
    systemd.targets.sleep.enable = lib.mkForce true;

    # custom service for autowake
    systemd.services."autowake" = {
      restartIfChanged = false;
      stopIfChanged = false;

      startAt = cfg.time.sleep;
      # put to sleep until wake time :
      script = ''
        NEXT=$(systemd-analyze calendar "${cfg.time.wakeup}" | sed -n 's/\W*Next elapse: //p')
        AS_SECONDS=$(date +%s -d "$NEXT")
        echo "will wakeup on $(NEXT)"
        rtcwake -s $(AS_SECONDS)
      '';
    };
  };
}
