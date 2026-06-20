{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  nixpkgs.config.allowUnfree = true;

  boot.kernelParams = [ "nouveau.modeset=0" ];

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="leds", KERNEL=="asus::kbd_backlight", ATTR{brightness}="3"
  '';

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

  security.wrappers.clash-verge = {
    source = lib.getExe pkgs.clash-verge-rev;
    capabilities = "cap_net_admin,cap_net_bind_service+ep";
    owner = "root";
    group = "root";
  };

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

  # programs.nix-ld = {
  #   enable = true;
  #   libraries = with pkgs; [
  #     alsa-lib
  #     at-spi2-atk
  #     at-spi2-core
  #     atk
  #     cairo
  #     cups
  #     dbus
  #     expat
  #     fontconfig
  #     freetype
  #     gdk-pixbuf
  #     glib
  #     gtk3
  #     libdrm
  #     libglvnd
  #     libnotify
  #     libpulseaudio
  #     libuuid
  #     libxkbcommon
  #     mesa
  #     nspr
  #     nss
  #     pango
  #     stdenv.cc.cc
  #     systemd
  #     xorg.libX11
  #     xorg.libXScrnSaver
  #     xorg.libXcomposite
  #     xorg.libXcursor
  #     xorg.libXdamage
  #     xorg.libXext
  #     xorg.libXfixes
  #     xorg.libXi
  #     xorg.libXrandr
  #     xorg.libXrender
  #     xorg.libXtst
  #     xorg.libxcb
  #   ];
  # };

  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons ];
  };

  time.timeZone = "Asia/Shanghai";
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.power-profiles-daemon.enable = false;

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

  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.niri.enable = true;
  

  services.displayManager.sddm.enable = true;
 

  services.xserver.videoDrivers = [ "modesetting" ];
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

  programs.clash-verge = {
    enable = true;
    serviceMode = true;
  };

  environment.systemPackages = with pkgs; [
    # Version control
    git

    # Python
    python3
    uv
    ruff
    pyright

    # C and C++
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

    bluez
    bluez-tools
    kdePackages.bluedevil

    kdePackages.konsole
    kdePackages.dolphin
    kdePackages.polkit-kde-agent-1
    firefox
    google-chrome
    home-manager
    nodejs_22
    vscode
    qq
    helix
  ];

  users.users.cloudygirl = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  system.stateVersion = "26.05";
  # services.displayManager.ly.enable = true;
}
