{ lib, config, nonlib, ... }:
with lib; with nonlib; {
  options.nonOS = {
    hostname = mkMandatoryOption {
      name = "hostname";
      description = "The system hostname.";
      type = types.str;
    };
    timezone = mkOption {
      type = types.str;
      default = "Europe/Paris";
      description = "The system timezone.";
    };
    system = mkOption {
      type = types.str;
      default = "x86_64-linux";
      description = "The target system architecture.";
    };
  };

  config = {
    networking.hostName = config.nonOS.hostname;
    time.timeZone = config.nonOS.timezone;
  };
}
