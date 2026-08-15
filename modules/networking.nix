{ ... }:

{
  # 主机名、网络管理和网络托盘程序
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # SSH 远程连接
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
  };

  # ttyd 网页终端
  networking.firewall.allowedTCPPorts = [ 7681 ];
}
