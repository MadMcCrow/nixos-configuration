# server/nextcloud/apps.nix
# 	nextcloud addons
#   WARNING : those use old shool licence naming
#             these will eventually gets replaced by correct values
{ pkgs, lib, config, ... }:
with builtins;
with lib;
let
  # shortcuts
  nxt = config.nixos.server.nextcloud;
  cfg = nxt.apps;

  cospend = pkgs.fetchNextcloudApp {
    url =
      "https://github.com/julien-nc/cospend-nc/releases/download/v1.5.10/cospend-1.5.10.tar.gz";
    sha256 = "sha256-SQ6tcwD1ThL41n3puZXMk8DEvpdr9H4hQ3Rd5ceY6eU=";
    license = "agpl3"; # license = lib.licenses.agpl3Only;

  };

  # onlyOffice = pkgs.fetchNextcloudApp {
  #   sha256 = "sha256-Pzd3Fk3EmTc0uPo0DWaDPLsSLso6SXP+Q6uxSP1dbZs=";
  #   url = "https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v8.1.0/onlyoffice.tar.gz";
  #   license ="asl20"; # license = lib.licenses.asl20;
  # };

  tasks = pkgs.fetchNextcloudApp {
    sha256 = "sha256-zMMqtEWiXmhB1C2IeWk8hgP7eacaXLkT7Tgi4NK6PCg=";
    url =
      "https://github.com/nextcloud/tasks/releases/download/v0.15.0/tasks.tar.gz";
    license = "agpl3";
  };

in {
  # interface :
  options.nixos.server.nextcloud.apps = {
    enable = mkEnableOption "nextcloud" // { default = true; };
  };

  # implementation
  config = mkIf (cfg.enable && nxt.enable) {
    services.nextcloud = {
      appstoreEnable = false;
      extraAppsEnable = true;
      extraApps = { inherit cospend tasks; };
    };
  };
}
