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

  # Tailscale VPN - 手机远程连接电脑
  services.tailscale = {
    enable = true;
    openFirewall = true;
    # 不接管系统 DNS：Tailscale 的 MagicDNS(100.100.100.100) 转发层不稳定，
    # 曾导致全局域名解析超时（Could not resolve host）。
    # 关闭后 DNS 回归 NetworkManager 直连路由器，Tailscale 仅提供 VPN 隧道。
    extraSetFlags = [ "--accept-dns=false" ];
  };

  # ttyd 网页终端
  networking.firewall.allowedTCPPorts = [ 7681 ];
}
