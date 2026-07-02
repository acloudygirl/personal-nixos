{ config, lib, pkgs, ... }:

let
  # Markdown -> PDF shortcut. After switching, use:
  #   mdpdf note.md [output.pdf]
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
  # Imported modules: hardware scan, login theme, fonts and Home Manager are
  # wired from flake.nix; this file keeps machine-level options.
  imports = [
    ./hardware-configuration.nix
    ./sddm-theme.nix
  ];

  # Nixpkgs policy: needed for packages such as Chrome, VS Code and QQ.
  nixpkgs.config.allowUnfree = true;

  # Kernel and low-level device tweaks.
  boot.kernelParams = [ "nouveau.modeset=0" ];

  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="leds", KERNEL=="asus::kbd_backlight", ATTR{brightness}="3"
  '';

  # Wayland compatibility: enable Xwayland and prefer native Wayland backends
  # for Electron/Chromium-style applications.
  programs.xwayland.enable = true;
  environment.variables = {
    NIXOS_OZONE_WL = "1";
  };

  # ASUS keyboard backlight: force it on at boot and when the LED device appears.
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

  # Nix command behavior and binary caches.
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

  # Boot loader: GRUB in EFI mode, with OS probing for other installed systems.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };

  # Locale and input method.
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons ];
  };

  # Time, hostname and network applet.
  time.timeZone = "Asia/Shanghai";
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  # Bluetooth support.
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Power policy: prefer quiet/low-power behavior.
  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
  };

  services.power-profiles-daemon.enable = false;

  # TLP battery and thermal tuning.
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

  # Extra battery-mode CPU throttling for a quiet profile.
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

  # Desktop stack: Plasma is available, Niri is enabled, SDDM is the display
  # manager. The detailed SDDM theme lives in sddm-theme.nix.
  services.xserver.enable = true;
  services.desktopManager.plasma6.enable = true;
  programs.niri.enable = true;

  services.displayManager.sddm.enable = true;

  services.xserver.videoDrivers = [ "modesetting" ];

  # Flatpak support and automatic Flathub remote setup.
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

  # System-wide command line tools, desktop apps and development toolchains.
  environment.systemPackages = with pkgs; [
    # Version control
    git
    gnumake
    mdpdf
    fastfetch
    v2rayn
    sing-box

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

    # Bluetooth tools
    bluez
    bluez-tools
    kdePackages.bluedevil

    # Desktop applications
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
    marktext # Markdown reader
    sioyek # PDF reader
    pandoc # Markdown -> PDF
    texliveFull
  ];

  # Allow sing-box to create network interfaces and bind privileged ports without
  # running the whole application as root.
  security.wrappers.sing-box = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin,cap_net_bind_service+ep";
    source = "${pkgs.sing-box}/bin/sing-box";
  };

  # v2rayN expects the sing-box core at this user-writable path. Link it to the
  # capability-enabled wrapper from security.wrappers above.
  system.activationScripts.v2rayn-sing-box-core.text = ''
    ${pkgs.coreutils}/bin/install -d -o cloudygirl -g users -m 0755 /home/cloudygirl/.local/share/v2rayN/bin/sing_box
    ${pkgs.coreutils}/bin/ln -sfn /run/wrappers/bin/sing-box /home/cloudygirl/.local/share/v2rayN/bin/sing_box/sing-box
    ${pkgs.coreutils}/bin/chown -h cloudygirl:users /home/cloudygirl/.local/share/v2rayN/bin/sing_box/sing-box
  '';

  # Main local user.
  users.users.cloudygirl = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  # NixOS release compatibility level. Do not change casually.
  system.stateVersion = "26.11";

  # services.displayManager.ly.enable = true;
}
