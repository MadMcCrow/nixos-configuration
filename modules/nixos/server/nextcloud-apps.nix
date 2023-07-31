# server/nextcloud-apps.nix
# 	mextcloud addons
{ pkgs , ... }:
{
  cospend = pkgs.fetchNextcloudApp {
    sha256 = "sha256-Pzd3Fk3EmTc0uPo0DWaDPLsSLso6SXP+Q6uxSP1dbZs=";
    url = "https://github.com/julien-nc/cospend-nc/releases/download/v1.5.10/cospend-1.5.10.tar.gz";
  };

  onlyOffice = pkgs.fetchNextcloudApp {
    sha256 = "sha256-cDX4HQItUbuNmUcmdY03Lx62yyQbieqCrM3LQABezA0=";
    url = "https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v8.1.0/onlyoffice.tar.gz";
  };

  tasks = pkgs.fetchNextcloudApp {
    sha256 = "sha256-zMMqtEWiXmhB1C2IeWk8hgP7eacaXLkT7Tgi4NK6PCg=";
    url = "https://github.com/nextcloud/tasks/releases/download/v0.15.0/tasks.tar.gz";
  };
}
