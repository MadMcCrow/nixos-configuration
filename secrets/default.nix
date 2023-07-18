# secrets/default.nix
#   module for adding our secrets to the configurations
{ nixpkgs, config, agenix, ... }: {
  config = {
    age.secrets.nextcloud = {
      file = ./nextcloud.age;
      owner = "nextcloud";
      group = "nextcloud";
    };
  };
}
