# use authelia in nixos
{lib, config, ...} :
{
  # auth
  imports = [./authelia.nix];  
  options.nixos.web.auth = with lib; {
    enable = mkEnableOption "authentification service for web" // {default = true;};
  };
}