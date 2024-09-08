# firefox.nix
# 	cooler firefox setup
{
  programs.firefox = {
    enable = true;

    # enable chromecast (not available in 23.11)
    # nativeMessagingHosts = [ pkgs.fx-cast-bridge ];

    # profile is sync with firefox sync
    # profiles."0" = {
    #   id = 0;
    #   isDefault = true;
    #   name = "0";
    #   settings = {
    #     "browser.sessionstore.warnOnQuit" = true;
    #     "browser.sessionstore.resume_from_crash" = false;
    #     "general.useragent.locale" = "en-GB";
    #   };
    #   extensions = with pkgs.nur.repos.rycee.firefox-addons; [
    #     # see: https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
    #     gopass-bridge
    #     # https-everywhere
    #     link-cleaner
    #     privacy-badger
    #     tree-style-tab
    #     multi-account-containers
    #     ublock-origin
    #     vimium
    #     sidebery
    #   ];
    # };
  };

  # Add default associations

  home.sessionVariables.BROWSER = "firefox";

  xdg.mimeApps.defaultApplications = builtins.listToAttrs (
    map
      (mimeType: {
        name = mimeType;
        value = [ "firefox.desktop" ];
      })
      [
        "application/json"
        "application/pdf"
        "application/x-extension-htm"
        "application/x-extension-html"
        "application/x-extension-shtml"
        "application/x-extension-xhtml"
        "application/x-extension-xht"
        "application/xhtml+xml"
        "text/html"
        "text/xml"
        "x-scheme-handler/about"
        "x-scheme-handler/ftp"
        "x-scheme-handler/http"
        "x-scheme-handler/unknown"
        "x-scheme-handler/https"
      ]
  );

}
