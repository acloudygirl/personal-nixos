{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/desktop.nix
    ./modules/hardware-tweaks.nix
    ./modules/locale.nix
    ./modules/networking.nix
    ./modules/nix-settings.nix
    ./modules/packages.nix
    ./modules/power.nix
    ./modules/proxy-tools.nix
    ./modules/users.nix
    ./sddm-theme.nix
    ./modules/docker-setting.nix
  ];

  # NixOS 版本兼容级别
  system.stateVersion = "26.11";
}
