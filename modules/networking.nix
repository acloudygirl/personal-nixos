{ ... }:

{
  # 主机名、网络管理和网络托盘程序
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
}
