{ lib, pkgs, noctalia, zen-browser, ... }:

let
  # DeepSeek Harness Web 启动器：先拉起后端，再用谷歌浏览器打开
  dsh-web-launch = pkgs.writeShellApplication {
    name = "dsh-web-launch";
    runtimeInputs = with pkgs; [ curl pnpm nodejs_22 google-chrome ];
    text = ''
      HARNESS_DIR="/home/cloudygirl/deepseek-harness"
      URL="http://127.0.0.1:3080"
      LOG="/tmp/dsh-web.log"

      # 后端未运行则先启动
      if ! curl -sf -o /dev/null "$URL"; then
        cd "$HARNESS_DIR" || exit 1
        nohup pnpm dsh web >> "$LOG" 2>&1 &
        for _ in {1..60}; do
          curl -sf -o /dev/null "$URL" && break
          sleep 1
        done
      fi

      exec google-chrome "$URL"
    '';
  };
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.cloudygirl = { config, ... }: {
      imports = [
        noctalia.homeModules.default
        ./shell.nix
        ./apps.nix
        ./mime.nix
      ];

      home.stateVersion = "26.05";

      # npm / cargo 全局安装目录加入 PATH（codebuddy/codex/qq-wayland-clipboard 等命令）
      home.sessionPath = [
        "$HOME/.npm-global/bin"
        "$HOME/.cargo/bin"
      ];

      home.packages = with pkgs; [
        xwayland-satellite
        btop # 现代版 top：彩色图表 + GPU 监控
        kitty
        zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
        dsh-web-launch
        swaylock-effects
        swayidle
        cmatrix
      ];

      programs.noctalia = {
        enable = true;
        systemd.enable = true;
      };

      xdg.configFile."noctalia/config.json".source =
        ./config/noctalia/noctalia-base-settings-v4.json;

      systemd.user.services.polkit-kde-agent = {
        Unit = {
          Description = "KDE PolicyKit Authentication Agent";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      systemd.user.services.swayidle = {
        Unit = {
          Description = "Swayidle (idle management for Niri)";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          Requisite = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 300 'swaylock -f' timeout 301 'niri msg action power-off-monitors' before-sleep 'swaylock -f'";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      xdg.dataFile."applications/wps-office-wps.desktop".source = ./config/wps-desktop/wps-office-wps.desktop;
      xdg.dataFile."applications/wps-office-et.desktop".source = ./config/wps-desktop/wps-office-et.desktop;
      xdg.dataFile."applications/wps-office-wpp.desktop".source = ./config/wps-desktop/wps-office-wpp.desktop;

      xdg.dataFile."applications/dsh-web.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=DeepSeek Harness
        Comment=DeepSeek Harness Web UI
        Comment[zh_CN]=DeepSeek Harness 网页界面
        Exec=${dsh-web-launch}/bin/dsh-web-launch
        Icon=browser
        Terminal=false
        Categories=Development;
        StartupNotify=false
      '';

      xdg.configFile."Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <submenu></submenu>
          <unique-id>1783058739735464-1</unique-id>
          <command>${pkgs.kitty}/bin/kitty --working-directory %f</command>
          <description>Open kitty in this directory</description>
          <range></range>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
        </action>
        <action>
          <icon>system-file-manager</icon>
          <name>Open as Administrator</name>
          <submenu></submenu>
          <unique-id>1783067653000000-1</unique-id>
          <command>${pkgs.thunar}/bin/thunar admin://%f</command>
          <description>Open this directory with administrator permissions</description>
          <range></range>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
        </action>
        </actions>
      '';

      xdg.configFile."swaylock/config".source = ./config/swaylock/config;

      xdg.configFile."kde-mimeapps.list".source =
        config.xdg.configFile."mimeapps.list".source;
      xdg.configFile."niri-mimeapps.list".source =
        config.xdg.configFile."mimeapps.list".source;
      xdg.dataFile."applications/kde-mimeapps.list".source =
        config.xdg.configFile."mimeapps.list".source;
      xdg.dataFile."applications/niri-mimeapps.list".source =
        config.xdg.configFile."mimeapps.list".source;
    };

    backupFileExtension = ".bak";
  };
}
