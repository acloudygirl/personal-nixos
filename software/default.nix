{ lib, pkgs, noctalia, zen-browser, ... }:

let
  chromeProxyAuto = pkgs.writeShellScriptBin "chrome-proxy-auto" ''
    for _ in $(seq 1 20); do
      if ${pkgs.iproute2}/bin/ss -ltn | ${pkgs.gnugrep}/bin/grep -q '127\.0\.0\.1:10808'; then
        exec ${pkgs.google-chrome}/bin/google-chrome \
          --proxy-server=socks5://127.0.0.1:10808 \
          --host-resolver-rules='MAP * ~NOTFOUND , EXCLUDE 127.0.0.1' \
          "$@"
      fi
      sleep 0.5
    done

    exec ${pkgs.google-chrome}/bin/google-chrome \
      --proxy-server=socks5://127.0.0.1:10808 \
      --host-resolver-rules='MAP * ~NOTFOUND , EXCLUDE 127.0.0.1' \
      "$@"
  '';
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

      home.packages = with pkgs; [
        xwayland-satellite
        kitty
        chromeProxyAuto
        zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
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

      xdg.dataFile."applications/wps-office-wps.desktop".source = ./config/wps-desktop/wps-office-wps.desktop;
      xdg.dataFile."applications/wps-office-et.desktop".source = ./config/wps-desktop/wps-office-et.desktop;
      xdg.dataFile."applications/wps-office-wpp.desktop".source = ./config/wps-desktop/wps-office-wpp.desktop;

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
