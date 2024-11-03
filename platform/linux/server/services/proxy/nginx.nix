# nginx is a webserver, used mostly as a reverse proxy 
# TODO : regroup all of the nginx settings here and add 
# a simple option to proxy addresses
{config, lib, ...} :
let 
cfg = config.nixos.server.proxy.nginx;
in
{
options.nixos.server.proxy.nginx = { 
  enable = lib.mkEnableOption "nginx as reverse proxy";
};

    config = lib.mkIf cfg.enable {

  # Use recommended settings
  services.nginx = {
    recommendedGzipSettings = lib.mkDefault true;
    recommendedOptimisation = lib.mkDefault true;
    recommendedProxySettings = lib.mkDefault true;
    recommendedTlsSettings = lib.mkDefault true;
  };
};
}