# autowake.nix
# automatically wake-up computer on timer
{lib, config, ...} :
{
  options.linux.autowake = with lib; {
      enable = mkEnableOption "auto sleep/wake up timer";
      time = {
        sleep = mkNonEmptyStrOption "time to put to sleep" "22:00";
        wakeup = mkNonEmptyStrOption "time to wake up" "07:00";
      };
    };
    # change systemd config to have a wake on date service
    config.systemd = lib.mkIf config.linux.autowake.enable {
        targets = {
          sleep.enable = lib.mkDefaults config.linux.autowake.enable;
        };
        services."autowake" = {
            restartIfChanged = false;
            stopIfChanged = false;
            startAt = cfg.autowake.time.sleep;
            # put to sleep until wake time :
            script = ''
              NEXT=$(systemd-analyze calendar "${cfg.autowake.time.wakeup}" | sed -n 's/\W*Next elapse: //p')
              AS_SECONDS=$(date +%s -d "$NEXT")
              echo "will wakeup on $(NEXT)"
              rtcwake -s $(AS_SECONDS)
            '';
        };
    };
}
