# config for home manager shared between nixos and macOS
{ self, ...} :
{
config = {
    # home manager config users :
    home-manager = {
      extraSpecialArgs = {
        inherit self;
      };
    };
};
}