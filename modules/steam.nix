{ pkgs, ... }:
{
  programs.steam.enable = true;
  programs.steam.fontPackages = with pkgs; [
    noto-fonts
    noto-fonts-cjk-sans
  ];
}
