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
  # Nix 命令行为和二进制缓存，使用科大，上交，官方，南大作为源地址
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://noctalia.cachix.org"
      # 南大镜像同步中（HTTP 500），暂时禁用；同步完成后恢复：
      # "https://mirrors.nju.edu.cn/nix-channels/store"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
    trusted-users = [ "root" "cloudygirl" ];
  };

  # 代理由 nix-proxy-on / nix-proxy-off 动态控制，不再硬编码
  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };

  # 自动垃圾回收：每周清理旧 generation 和 store，防止磁盘占满
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
}
