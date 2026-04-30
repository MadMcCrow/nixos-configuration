# server/nextcloud/apps.nix
# 	nextcloud addons
#   WARNING : those use old shool licence naming
#             these will eventually gets replaced by correct values
#   TODO :
#           - create custom fetch function for github
#           - update license to correct value
#           - https://apps.nextcloud.com/apps/duplicatefinder
#           - https://apps.nextcloud.com/apps/side_menu
#           - https://apps.nextcloud.com/apps/unroundedcorners
#           - https://apps.nextcloud.com/apps/integration_homeassistant
{ config, ... }: {
  config.services.nextcloud.extraApps = {

    # nixpkgs :
    # also already packaged in nixos :
    #   - bookmarks
    #   - end_to_end_encryption
    #   - files_markdown
    #   - files_texteditor
    #   - forms
    #   - notes
    #   - onlyoffice
    #   - unsplash
    #   - unroundedcorners
    #   - qownnotesapi
    #   - registration
    #   - ...
    inherit (config.services.nextcloud.package.packages.apps)
      contacts calendar tasks cospend onlyoffice unroundedcorners
      end_to_end_encryption;

    # for the rest use :
    # myApp = fetchNextcloudApp {
    #  sha256 = "";
    #  url = "https://github.com/nextcloud/aaa/releases/download/vxxxx/aaa.tar.gz";
    #  license = "agpl3"; # or asl20
    # };

  };
}
