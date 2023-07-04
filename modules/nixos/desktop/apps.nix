# desktop/apps.nix
# 	userspace apps that are provided directly, either because not present on home manager
#   or because the HM-configuration is lacking for them
#   TODO : move steam to separate module
#   TODO : move discord to separate module
{ pkgs, config, lib, inputs, ... }:
with builtins;
with lib;
let
  #config interface
  cfg = config.nixos.apps;
  
  # not working (cannot find inputs)
  # stable pkgs for packages being broken on instable (like steam)
  #stable-pkgs = nixpkgs-stable.legacyPackages.${pkgs.system};
  stable-pkgs = pkgs;

  # helper functions
  mkEnableOptionDefault = desc : default: (mkEnableOption (mdDoc desc)) // { inherit default;};
  mkAppOptions = list : listToAttrs (map (x : {name = x; value = {enable = mkEnableOptionDefault x  true;};}) list);
  isAppEnabled = str : cfg."${str}".enable == true; # TODO : replace with hasAttr/GetAttr 
  condList = cond : list : if cond then list else [];

  # Discord use OpenASAR for faster start-up times
  cfgDiscord = cfg.discord.enable;
  OpenASAR = self: super: { discord = super.discord.override { withOpenASAR = true; }; };
  discordApps = ["discord" "nss_latest"]; 
  discordUnfree = ["discord"];

  # final list of apps to have on our systems
  defaultApps =  [ "nixfmt" "bash" "zsh" "exa" "nano" "wget" "openssl" "git" "curl" "zip" "neofetch" ];

  # steam :
  # TODO : Add GameScope to have steamdeck ui and compositor for better framerate
  # TODO : add pufferpanel for server
  # TODO : steam stable
  cfgSteam = cfg.steam.enable;
  steamApps = [ "steam" "steam-run" "steamcmd" "libglvnd" ];
  steamPlus = self: super: { steam = super.steam.override {extraPkgs = pkgs : [ pkgs.libgdiplus pkgs.libpng];};};
  steamUnfree = ["steam-original" "steam" "steam-run" "steamcmd"];

  # generate app list for config
  appList = (filter (isAppEnabled) defaultApps) ++ (condList cfgDiscord discordApps) ++ (condList cfgSteam steamApps);
  unfreePackages = concatLists [(condList cfgDiscord discordUnfree) (condList cfgSteam steamUnfree)];
  
in 
{
  # interface
  options.nixos.apps = {
    enable =  mkEnableOption (mdDoc "system-wide apps") // { default = true; };
    steam.enable   = mkEnableOptionDefault "steam"   true;
    discord.enable = mkEnableOptionDefault "discord" true;
  } // mkAppOptions defaultApps;

  #config
  config = mkIf cfg.enable {

    # Packages
    environment.systemPackages = map (x : pkgs."${x}") appList;

    packages = {
      inherit unfreePackages;
      overlays = (condList cfgDiscord  [ OpenASAR ]) ++ (condList cfgSteam [ steamPlus ]);
    };

    # ZSH
    programs.zsh = {
      enable = isAppEnabled "zsh";
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      histSize = 100;
      shellAliases = { ls = "exa"; };
      ohMyZsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "robbyrussell";
      };
    };
    users.defaultUserShell = if isAppEnabled "zsh" then pkgs.zsh else pkgs.bash;
    environment.shells = [ pkgs.zsh pkgs.bash ];
    security.sudo.extraConfig = "Defaults        lecture = never";

    # STEAM
    hardware.steam-hardware.enable = cfgSteam; # Steam udev rules
    programs.steam = mkIf cfgSteam {
      # uses stable instead of latest
      package = stable-pkgs.steam;
      enable = cfgSteam;
      # Open ports in the firewall for Steam Remote Play and Source Dedicated Server
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
    # some games might require gamemode
    programs.gamemode = {
      enable = cfgSteam;
      settings.general.inhibit_screensaver = 0;
    };
  };
}
