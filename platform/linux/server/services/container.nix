# function to make containers :
{datadir, config } :
{
      autoStart = true;
      # TODO : use bindings instead of host networking
      privateNetwork = false;
      nixpkgs = pkgs.path;
      ephemeral = true;
      bindMounts = {
        "/" = {
          hostPath = "${dataDir}";
          isReadOnly = false;
        };
      };
      config = config // {
        system.stateVersion = config.system.stateVersion;
      };
    }
