# Home manager support for macOS machines
{
  mac-app-util,
  home-manager,
  self,
  ...
}:
{
  imports = [
    mac-app-util.darwinModules.default
    home-manager.darwinModules.home-manager
  ];

  config = {
    home-manager = {
      sharedModules = [ 
        mac-app-util.homeManagerModules.default
        ];
      extraSpecialArgs = {
        inherit self;
      };
    };
  };
}
