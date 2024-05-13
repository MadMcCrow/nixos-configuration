{ config, ... }: {
  # interface
  options.nixos.server.services.adguard = with lib; {
    enable = mkEnableOption "adguard instance";
  };

  config = lib.mkIf cfg.enable {

    # our actual container :
    containers."adguard" = {
      # start at boot :
      autoStart = true;
      # container networking :
      # TODO : use bindings instead of host networking
      privateNetwork = false;
      # use host nix-store and nixpkgs config
      nixpkgs = pkgs.path;
      ephemeral = true; # do not store anything
    };
  };
}
