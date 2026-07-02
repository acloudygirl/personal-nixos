{ config, lib, pkgs, ... }:

let
  # Markdown 转 PDF
  # .md文件转化为.pdf命令缩减：mdpdf note.md [output.pdf]
  mdpdf = pkgs.writeShellScriptBin "mdpdf" ''
    set -euo pipefail

    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
      echo "Usage: mdpdf INPUT.md [OUTPUT.pdf]" >&2
      exit 2
    fi

    input="$(${pkgs.coreutils}/bin/realpath "$1")"
    if [ "$#" -eq 2 ]; then
      output="$(${pkgs.coreutils}/bin/realpath -m "$2")"
    else
      output="''${input%.*}.pdf"
    fi

    workdir="$(${pkgs.coreutils}/bin/dirname "$input")"
    filename="$(${pkgs.coreutils}/bin/basename "$input")"

    cd "$workdir"
    exec ${pkgs.pandoc}/bin/pandoc "$filename" \
      -d ${./notes/template/pandoc.yaml} \
      -o "$output"
  '';
in

{
  # 导入模块：硬件扫描、登录主题；字体和 Home Manager 在 flake.nix 中接入
  # 这个文件保留机器级选项
  imports = [
    ./hardware-configuration.nix
    ./sddm-theme.nix
  ];

  # Chrome, VS Code and QQ必要权限
  nixpkgs.config.allowUnfree = true;

  # 内核和底层设备调整
  boot.kernelParams = [ "nouveau.modeset=0" ];

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="leds", KERNEL=="asus::kbd_backlight", ATTR{brightness}="3"
  '';

  # Wayland 兼容性：启用 Xwayland，并让 Electron/Chromium 类应用优先使用原生 Wayland 后端
  programs.xwayland.enable = true;
  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

  # 华硕键盘背光：启动时以及 LED 设备出现时强制打开
  systemd.services.keyboard-backlight-on = {
    description = "Keep keyboard backlight on";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      led=/sys/class/leds/asus::kbd_backlight
      if [ -w "$led/brightness" ]; then
        cat "$led/max_brightness" > "$led/brightness"
      fi
    '';
  };

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

  # 引导加载器：EFI 模式下的 GRUB，并探测其它已安装系统
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  # 区域设置和输入法
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons ];
  };

  # 时间、主机名和网络托盘程序
  time.timeZone = "Asia/Shanghai";
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # 蓝牙
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # 电源方案
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.power-profiles-daemon.enable = false;

  # TLP 电池和温控调校
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_power";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_BOOST_ON_AC = 0;
      CPU_BOOST_ON_BAT = 0;
      CPU_MAX_PERF_ON_AC = 65;
      CPU_MAX_PERF_ON_BAT = 45;
      PLATFORM_PROFILE_ON_AC = "quiet";
      PLATFORM_PROFILE_ON_BAT = "quiet";
      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "med_power_with_dipm";
      USB_AUTOSUSPEND = 1;
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      SOUND_POWER_SAVE_ON_AC = 1;
      SOUND_POWER_SAVE_ON_BAT = 1;
      NMI_WATCHDOG = 0;
    };
  };

  # 不插电时触发安静配置，会有额外电池模式 CPU 限速
  systemd.services.quiet-cpu-profile = {
    description = "Keep CPU in a quiet low-power profile";
    wantedBy = [ "multi-user.target" ];
    after = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      if [ "$(cat /sys/class/power_supply/ADP0/online 2>/dev/null || echo 1)" = "1" ]; then
        exit 0
      fi

      if [ -w /sys/devices/system/cpu/intel_pstate/no_turbo ]; then
        echo 1 > /sys/devices/system/cpu/intel_pstate/no_turbo
      fi

      if [ -w /sys/devices/system/cpu/intel_pstate/max_perf_pct ]; then
        echo 45 > /sys/devices/system/cpu/intel_pstate/max_perf_pct
      fi

      for pref in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
        [ -w "$pref" ] && echo power > "$pref"
      done
    '';
  };

  # 桌面栈：Plasma 作为应急备用桌面，Niri为主桌面，SDDM 是显示管理器，掌管登录界面
  # SDDM 主题细节放在 sddm-theme.nix。
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
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

  # 全系统命令行工具、桌面应用和开发工具链
  environment.systemPackages = with pkgs; [
    # 版本控制
    git
    gnumake
    # md-pdf转换命令
    mdpdf
    fastfetch
    #梯子
    v2rayn
    sing-box

    # Python
    python3
    uv
    ruff
    pyright

    # C 和 C++
    gcc
    clang
    clang-tools
    cmake
    ninja
    gdb
    lldb

    # Rust
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    # 蓝牙工具
    bluez
    bluez-tools
    kdePackages.bluedevil

    # 桌面应用
    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.polkit-kde-agent-1
    firefox
    google-chrome
    home-manager
    nodejs_22
    vscode
    qq
    helix #.nix文件编辑器，nano替代
    kdePackages.gwenview # 图片查看器
    haruna # 视频播放器
    kdePackages.elisa # 音乐播放器
    marktext # Markdown 阅读器
    sioyek # PDF 阅读器
    pandoc # Markdown 转 PDF
    texliveFull #md转pdf渲染库

    #压缩软件
    kdePackages.ark
    p7zip
    unzip
    zip
    unrar
  ];

  # 允许 sing-box 创建网络接口并绑定特权端口，启用TUN
  # 不需要让整个应用以 root 身份运行
  security.wrappers.sing-box = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin,cap_net_bind_service+ep";
    source = "${pkgs.sing-box}/bin/sing-box";
  };

  # v2rayN 需要在这个用户可写路径找到 sing-box 核心
  # 将它链接到上面 security.wrappers 生成的带能力包装器
  system.activationScripts.v2rayn-sing-box-core.text = ''
    ${pkgs.coreutils}/bin/install -d -o cloudygirl -g users -m 0755 /home/cloudygirl/.local/share/v2rayN/bin/sing_box
    ${pkgs.coreutils}/bin/ln -sfn /run/wrappers/bin/sing-box /home/cloudygirl/.local/share/v2rayN/bin/sing_box/sing-box
    ${pkgs.coreutils}/bin/chown -h cloudygirl:users /home/cloudygirl/.local/share/v2rayN/bin/sing_box/sing-box
  '';

  # 主要本地用户
  users.users.cloudygirl = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # NixOS 版本兼容级别
  system.stateVersion = "26.11";

  # services.displayManager.ly.enable = true;
}
