# server/nextcloud-apps.nix
# 	mextcloud addons
{ pkgs , ... }:
{
  cospend = pkgs.fetchNextcloudApp {
    name = "cospend";
    sha256 = "03bf11c44173ac43f1149b7d0cdbb921c8fab39e3e0627e4e8d7f5583b6bc181";
    url = "https://github.com/julien-nc/cospend-nc/releases/download/v1.5.10/cospend-1.5.10.tar.gz";
    version = "1.5.10";
  };

  onlyOffice = pkgs.fetchNextcloudApp {
    name = "onlyOffice-nc";
    sha256 = "e2fccfecf20b3821e039c5107b3fc578f70f54e3409c002b37c1c50149bcc0d2";
    url = "https://github.com/ONLYOFFICE/onlyoffice-nextcloud/releases/download/v8.1.0/onlyoffice.tar.gz";
    version = "8.1.0";
  };

  tasks = pkgs.fetchNextcloudApp {
    name = "tasks";
    sha256 = "9e2cc95050722bbf0567a28f278cdf394e59f42940c61c2043b77e5f94c69ccf";
    url = "https://github.com/nextcloud/tasks/releases/download/v0.15.0/tasks.tar.gz";
    version = "0.15.0";
  };
}
