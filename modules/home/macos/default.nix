# Home manager support for macOS machines
{
  mac-app-util,
  home-manager,
  ...
}:
{
  imports = [
    mac-app-util.darwinModules.default
    home-manager.darwinModules.home-manager
    ../shared.nix
  ];

  config = {
    home-manager = {
      sharedModules = [
        mac-app-util.homeManagerModules.default
      ];
    };
  };
}
