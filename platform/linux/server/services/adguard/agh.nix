{ config, ... }: {
  services.adguardhome = {
    enable = true;
    settings = {
      bind_port = 8080;
      # users = [
      #   {
      #     name = "richard";
      #     password = "";
      #   }
      # ];
    };
  };
}
