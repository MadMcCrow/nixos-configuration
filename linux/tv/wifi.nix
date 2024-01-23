# TODO :
# if wifi needs to be set up manually :
{ config, pkgs, ... }: {
  networking.wireless.environmentFile = "/run/secrets/wireless.env";
  networking.wireless.networks."uwf-argo-air" = {
    hidden = true;
    auth = ''
      key_mgmt=WPA-EAP
      eap=PEAP
      phase2="auth=MSCHAPV2"
      identity="unx42"
      password="p@$$w0rd"
    '';
  };
}
