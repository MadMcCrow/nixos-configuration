# nextcloud/collabora.nix
# collabora server for nextcloud office :
# taken from https://gist.github.com/bburdette/95a4ee29f9b324bd19a14142e1e06810
{
  pkgs,
  config,
  lib,
  ...
}:
{
  # interface
  options.nc.office = with lib; {
    enable = mkEnableOption "collabora server for nextcloud";
    subdomain = mkOption {
      type = types.str;
      default = "office";
    };
  };

  # implementation
  config = lib.mkIf config.nc.office.enable {
    services.nginx.virtualHosts."${config.nc.office.subdomain}.${config.networking.domain}" = {
      forceSSL = true;
      enableACME = true;
      locations = {
        # static files
        "^~ /loleaflet" = {
          proxyPass = "http://localhost:9980";
          extraConfig = ''
            proxy_set_header Host $host;
          '';
        };
        # WOPI discovery URL
        "^~ /hosting/discovery" = {
          proxyPass = "http://localhost:9980";
          extraConfig = ''
            proxy_set_header Host $host;
          '';
        };

        # Capabilities
        "^~ /hosting/capabilities" = {
          proxyPass = "http://localhost:9980";
          extraConfig = ''
            proxy_set_header Host $host;
          '';
        };

        # download, presentation, image upload and websocket
        "~ ^/lool" = {
          proxyPass = "http://localhost:9980";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
            proxy_read_timeout 36000s;
          '';
        };

        # Admin Console websocket
        "^~ /lool/adminws" = {
          proxyPass = "http://localhost:9980";
          extraConfig = ''
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "Upgrade";
            proxy_set_header Host $host;
            proxy_read_timeout 36000s;
          '';
        };
      };
    };

    virtualisation.oci-containers = {
      backend = "docker";
      containers.collabora = {
        image = "collabora/code";
        imageFile = pkgs.dockerTools.pullImage {
          imageName = "collabora/code";
          imageDigest = "sha256:aab41379baf5652832e9237fcc06a768096a5a7fccc66cf8bd4fdb06d2cbba7f";
          sha256 = "sha256-M66lynhzaOEFnE15Sy1N6lBbGDxwNw6ap+IUJAvoCLs=";
        };
        ports = [ "9980:9980" ];
        environment = {
          domain = config.services.nextcloud.hostName;
          extra_params = "--o:ssl.enable=false --o:ssl.termination=true";
        };
        extraOptions = [
          "--cap-add"
          "MKNOD"
        ];
      };
    };
  };
}
