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
    ./modules/anki-fix.nix
    ./modules/power.nix
    ./modules/proxy.nix
    ./modules/users.nix
    ./sddm-theme.nix
    ./modules/docker-setting.nix
    ./modules/shell-aliases.nix
    ./modules/steam.nix
    ./modules/security
  ];

  # Swap文件配置（8G）
  swapDevices = [{
    device = "/swapfile";
    size = 8192;
  }];

  # ── 安全配置 ──
  security.aide = {
    enable = true;
    checkInterval = "weekly";
    logRetentionDays = 28;
    monitoredPaths = [
      "/etc p+i+n+u+g+s+m"
      "/etc/passwd p+i+n+u+g"
      "/etc/ssh/sshd_config p+i+n+u+g"
      "/etc/nixos p+i+n+u+g"
      "/home/cloudygirl/.ssh p+i+n+u+g"
    ];
    excludedPaths = [
      "!/tmp"
      "!/nix/store"
      "!/proc"
      "!/sys"
      "!/dev"
    ];
  };

  security.auditRules = {
    enable = true;
    rules = [
      "-w /etc/passwd -p wa -k identity"
      "-w /etc/shadow -p wa -k identity"
      "-w /etc/ssh/sshd_config -p wa -k sshd"
      "-w /etc/nixos -p wa -k nixos"
    ];
  };

  security.hardening = {
    enable = true;
    enableFirewall = true;
    allowedTCPPorts = [ 22 ];
    enableFail2ban = true;
  };

  # NixOS 版本兼容级别
  system.stateVersion = "26.11";
}
