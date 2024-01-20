{ config, pkgs, ... }:
{
  # Example
  #  config.virtualisation.oci-containers.containers = {
  #    hackagecompare = {
  #      image = "chrissound/hackagecomparestats-webserver:latest";
  #      ports = ["127.0.0.1:3010:3010"];
  #      volumes = [
  #        "/root/hackagecompare/packageStatistics.json:/root/hackagecompare/packageStatistics.json"
  #      ];
  #      cmd = [
  #        "--base-url"
  #        "\"/hackagecompare\""
  #      ];
  #    };
  #  };
}
