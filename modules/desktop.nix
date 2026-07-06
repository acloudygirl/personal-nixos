{ pkgs, ... }:

{
  # Wayland 兼容性：启用 Xwayland，并让 Electron/Chromium 类应用优先使用原生 Wayland 后端
  programs.xwayland.enable = true;
  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

  # 桌面栈：Plasma 作为应急备用桌面，Niri为主桌面，SDDM 是显示管理器，掌管登录界面
  # SDDM 主题细节放在 sddm-theme.nix。
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    dolphin
  ];
  programs.niri.enable = true;

  services.displayManager.sddm.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];

  # Flatpak 支持和 Flathub 远程仓库自动配置。
  services.flatpak.enable = true;
  systemd.services.flatpak-add-flathub = {
    description = "Add Flathub remote for Flatpak";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };
}
