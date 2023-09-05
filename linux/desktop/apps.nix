# desktop/apps.nix
# 	userspace apps that are provided directly, either because not present on home manager
#   or because the HM-configuration is lacking for them
#   TODO : CLEAN !
{ pkgs, config, lib, impermanence, ... }:
with builtins;
with lib;
let
  #config interface
  cfg = config.nixos.desktop.apps;

  # helper functions
  mkEnableOptionDefault = desc: default:
    (mkEnableOption (desc)) // {
      inherit default;
    };
  mkAppOptions = list:
    listToAttrs (map (x: {
      name = x;
      value = { enable = mkEnableOptionDefault x true; };
    }) list);
  isAppEnabled = str:
    cfg."${str}".enable == true; # TODO : replace with hasAttr/GetAttr
  condList = cond: list: if cond then list else [ ];

  # Discord use OpenASAR for faster start-up times
  cfgDiscord = cfg.discord.enable;
  OpenASAR = self: super: {
    discord = super.discord.override { withOpenASAR = true; };
  };
  discordApps = [ "discord" "nss_latest" ];
  discordUnfree = [ "discord" ];

  # final list of apps to have on our systems
  defaultApps = [
    "nixfmt"
    "bash"
    "zsh"
    "exa"
    "nano"
    "wget"
    "openssl"
    "git"
    "curl"
    "zip"
    "neofetch"
  ];

  #mkchromecast
  mkchromecast = [ "mkchromecast" ];

  flatpak = with pkgs; [ libportal libportal-gtk3 packagekit ];

  # generate app list for config
  appList = (filter (isAppEnabled) defaultApps)
    ++ (condList cfgDiscord discordApps) ++ mkchromecast;
  unfreePackages = concatLists [ (condList cfgDiscord discordUnfree) ];

in {
  # interface
  options.nixos.desktop.apps = {
    enable = mkEnableOptionDefault "system-wide apps" true;
    discord.enable = mkEnableOptionDefault "discord" true;
    flatpak.enable = mkEnableOptionDefault "flatpak apps" true;
  } // mkAppOptions defaultApps;

  # impermanence (for flatpak)
  imports = [ impermanence.nixosModules.impermanence ];

  #config
  config = mkIf cfg.enable {

    # Packages
    environment.systemPackages = map (x: pkgs."${x}") appList;

    packages = {
      inherit unfreePackages;
      overlays = (condList cfgDiscord [ OpenASAR ]);
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

    # for flatpak :
    xdg.portal.enable = cfg.flatpak.enable;
    services.packagekit.enable = cfg.flatpak.enable;
    services.flatpak.enable = cfg.flatpak.enable;

    # this folder is where the files will be stored (don't put it in tmpfs/zfs clean partition)
    # bind mounted from /persist/flatpak/var/lib/flatpak to /var/lib/flatpak
    environment.persistence."/nix/persist" = {
      directories = [ "/var/lib/flatpak" ];
    };
  };
}
