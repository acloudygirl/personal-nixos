{ ... }:

{
  # Chrome, VS Code 和 QQ必要权限
  nixpkgs.config.allowUnfree = true;
  # 图形提权认证，例如 Thunar 的 admin:// 访问和挂载磁盘时弹出密码框。
  security.polkit.enable = true;
  # 文件管理器挂载访问磁盘权限
  services.udisks2.enable = true;
  # 文件管理器缩略图查看
  services.tumbler.enable = true;
  # 文件管理器提权
  services.gvfs.enable = true;
  # Nix 命令行为和二进制缓存，使用南大，科大，官方作为源地址
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.nju.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://noctalia.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
    trusted-users = [ "root" "cloudygirl" ];
  };

  # nix-daemon 代理环境变量，重启后自动生效
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:10808";
    https_proxy = "http://127.0.0.1:10808";
    HTTP_PROXY = "http://127.0.0.1:10808";
    HTTPS_PROXY = "http://127.0.0.1:10808";
    no_proxy = "localhost,127.0.0.1,::1";
    NO_PROXY = "localhost,127.0.0.1,::1";
  };

  # 全局代理环境变量，所有用户（包括 root/sudo）都能用
  environment.variables = {
    http_proxy = "http://127.0.0.1:10808";
    https_proxy = "http://127.0.0.1:10808";
    HTTP_PROXY = "http://127.0.0.1:10808";
    HTTPS_PROXY = "http://127.0.0.1:10808";
    no_proxy = "localhost,127.0.0.1,::1";
    NO_PROXY = "localhost,127.0.0.1,::1";
  };
}
