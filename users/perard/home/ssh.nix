# all ssh related stuff for my user 
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    onlykey-agent
    onlykey-cli
  ];
}
