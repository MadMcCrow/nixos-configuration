# secrets/default.nix
#   module for adding our secrets to the configurations
{ nixpkgs, config, agenix, ... }: {
  config = {
    age = {
      # example :
      #secrets.nextcloud = {
      #file = ./nextcloud.age;
      #owner = "nextcloud";
      #group = "nextcloud";
      #};
      #identityPaths = ["/persist/secrets/nextcloud"];
    };
  };
}
