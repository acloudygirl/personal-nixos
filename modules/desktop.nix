{ lib, pkgs, ... }:

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

  # niri 为主桌面：明确默认会话，避免与 plasma6 的 defaultSession 冲突
  services.displayManager.defaultSession = lib.mkForce "niri";
  services.displayManager.sddm.enable = true;

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

  # 音频：显式启用 PipeWire 全栈，确保 pactl/pavucontrol 可用
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  environment.systemPackages = with pkgs; [
    pavucontrol    # 图形化音量控制，可切换输出设备
  ];

  # Flatpak 支持和 Flathub 远程仓库自动配置。
  programs.steam.enable = true;   #自动拉取steam32位库
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
