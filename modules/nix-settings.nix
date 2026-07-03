{ ... }:

{
  # Chrome, VS Code and QQ必要权限
  nixpkgs.config.allowUnfree = true;

  # Nix 命令行为和二进制缓存，使用南大，科大，官方作为源地址
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://mirrors.nju.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
  };
}
