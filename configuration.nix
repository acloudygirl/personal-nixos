{ pkgs,... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/desktop.nix
    ./modules/hardware-tweaks.nix
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/nvidia.nix
    ./modules/nix-settings.nix
    ./modules/packages.nix
    ./modules/qq-fix.nix
    ./modules/power.nix
    ./modules/proxy.nix
    ./modules/users.nix
    ./sddm-theme.nix
    ./modules/docker-setting.nix
    ./modules/shell-aliases.nix
    ./modules/steam.nix
  ];

  # Swap文件配置（8G）
  swapDevices = [{
    device = "/swapfile";
    size = 8192;
  }];

  # NixOS 版本兼容级别
  system.stateVersion = "26.11";
}
