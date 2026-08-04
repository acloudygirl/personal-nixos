{ pkgs, config, ... }:

{
  # OpenGL / Vulkan 基础
  hardware.graphics = {
    enable = true;
  };

  # NVIDIA 驱动
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    # 启用 DRM modesetting（Wayland 必需）
    modesetting.enable = true;

    # 使用稳定版驱动
    package = config.boot.kernelPackages.nvidiaPackages.production;

    # 使用开源内核模块（推荐 RTX 30+）
    open = true;

    # 启用 nvidia-settings GUI
    nvidiaSettings = true;

    # 电源管理
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    # PRIME offload — Intel 做主显卡，NVIDIA 按需调用
    prime = {
      offload.enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Wayland NVIDIA 环境变量
  environment.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  # 确保 nouveau 被禁用
  boot.blacklistedKernelModules = [ "nouveau" ];
  boot.extraModprobeConfig = ''
    blacklist nouveau
  '';

  # 安装 NVIDIA 相关工具
  environment.systemPackages = with pkgs; [
    pciutils
  ];
}
