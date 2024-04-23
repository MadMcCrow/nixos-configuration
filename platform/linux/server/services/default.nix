# linux/server/services.nix
#   services to run on a server
#
{ pkgs, config, lib, ... }:
let
  services = [
    ./dns.nix
    # ./seafile.nix
    ];

  mkModuleName = module:
    "${lib.strings.removeSuffix ".nix" (builtins.baseNameOf module)}";

  mkOptions = module:
    let m = import module { inherit pkgs config lib; };
    in lib.attrsets.optionalAttrs (m ? options) {
      name = mkModuleName module;
      value = m.options;
    };

  # build every service as a
  mkContainer = module: {
    name = mkModuleName module;
    value = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.11";
      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";
      config = { pkgs, lib, ... }@args:
        let m = import module (args // { inherit config; });
        in (if m ? config then m.config else m) // {
          # default service networking :
          networking.firewall.enable = true;
          networking.firewall.allowedTCPPorts = [ 80 ];
          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          networking.useHostResolvConf = lib.mkForce false;
          services.resolved.enable = true;
          system.stateVersion = "23.11";
        };
    };
  };
in {
  options.nixos.server.services =
    builtins.listToAttrs (lib.lists.remove { } (map mkOptions services));

  config = lib.mkIf config.nixos.server.enable {
    containers = (builtins.listToAttrs (map mkContainer services));
  };
}
