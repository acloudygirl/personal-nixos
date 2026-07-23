{ pkgs, ... }:
let
  proxyPort = "10808";
  noProxy = "localhost,127.0.0.1,::1";

  proxy = pkgs.writeShellScriptBin "proxy" ''
    set -euo pipefail

    if [ "$(${pkgs.coreutils}/bin/id -u)" -ne 0 ]; then
      exec ${pkgs.sudo}/bin/sudo "$0" "$@"
    fi

    dropin_dir=/run/systemd/system/nix-daemon.service.d
    dropin="$dropin_dir/10-proxy.conf"

    case "''${1:-}" in
      on)
        install -d -m 0755 "$dropin_dir"
        cat > "$dropin" <<EOF
[Service]
Environment="http_proxy=http://127.0.0.1:${proxyPort}"
Environment="https_proxy=http://127.0.0.1:${proxyPort}"
Environment="HTTP_PROXY=http://127.0.0.1:${proxyPort}"
Environment="HTTPS_PROXY=http://127.0.0.1:${proxyPort}"
Environment="no_proxy=${noProxy}"
Environment="NO_PROXY=${noProxy}"
EOF
        ${pkgs.systemd}/bin/systemctl daemon-reload
        ${pkgs.systemd}/bin/systemctl restart nix-daemon.service
        echo "nix-daemon proxy: on"
        ;;
      off)
        rm -f "$dropin"
        rmdir --ignore-fail-on-non-empty "$dropin_dir" 2>/dev/null || true
        ${pkgs.systemd}/bin/systemctl daemon-reload
        ${pkgs.systemd}/bin/systemctl restart nix-daemon.service
        echo "nix-daemon proxy: off"
        ;;
      status)
        if [ -f "$dropin" ]; then
          echo "nix-daemon proxy: on"
          ${pkgs.gnused}/bin/sed -n 's/^Environment="\([^"]*\)"$/  \1/p' "$dropin"
        else
          echo "nix-daemon proxy: off"
        fi
        ;;
      *)
        echo "Usage: proxy {on|off|status}" >&2
        exit 1
        ;;
    esac
  '';

  v2raynSystemProxyScript = pkgs.writeShellScript "v2rayn-system-proxy-linux" ''
    set -u
    mode="''${1:-}"
    proxy_ip="''${2:-127.0.0.1}"
    proxy_port="''${3:-10808}"
    ignore_hosts="''${4:-localhost,127.0.0.0/8,::1}"

    kwriteconfig_cmd() {
      if command -v kwriteconfig6 >/dev/null 2>&1; then
        command -v kwriteconfig6 && return 0
      fi
      if command -v kwriteconfig5 >/dev/null 2>&1; then
        command -v kwriteconfig5 && return 0
      fi
      return 1
    }

    set_kde_proxy() {
      local kde_config
      kde_config="$(kwriteconfig_cmd)" || return 0
      if [ "$mode" = "manual" ]; then
        "$kde_config" --file kioslaverc --group "Proxy Settings" --key ProxyType 1
        "$kde_config" --file kioslaverc --group "Proxy Settings" --key httpProxy "http://$proxy_ip:$proxy_port"
        "$kde_config" --file kioslaverc --group "Proxy Settings" --key httpsProxy "http://$proxy_ip:$proxy_port"
        "$kde_config" --file kioslaverc --group "Proxy Settings" --key ftpProxy "http://$proxy_ip:$proxy_port"
        "$kde_config" --file kioslaverc --group "Proxy Settings" --key socksProxy "socks://$proxy_ip:$proxy_port"
        "$kde_config" --file kioslaverc --group "Proxy Settings" --key NoProxyFor "$ignore_hosts"
      else
        "$kde_config" --file kioslaverc --group "Proxy Settings" --key ProxyType 0
      fi
      ${pkgs.dbus}/bin/dbus-send --type=signal /KIO/Scheduler org.kde.KIO.Scheduler.reparseSlaveConfiguration string:"" >/dev/null 2>&1 || true
    }

    set_gnome_proxy() {
      command -v gsettings >/dev/null 2>&1 || return 0
      if [ "$mode" = "manual" ]; then
        gsettings set org.gnome.system.proxy mode manual
        for protocol in http https ftp socks; do
          gsettings set "org.gnome.system.proxy.$protocol" host "$proxy_ip"
          gsettings set "org.gnome.system.proxy.$protocol" port "$proxy_port"
        done
        gsettings set org.gnome.system.proxy ignore-hosts "['$ignore_hosts']"
      else
        gsettings set org.gnome.system.proxy mode none
      fi
    }

    case "$mode" in
      manual)
        set_kde_proxy
        set_gnome_proxy
        if command -v proxy >/dev/null 2>&1; then
          proxy on || true
        fi
        ;;
      none)
        set_kde_proxy
        set_gnome_proxy
        if command -v proxy >/dev/null 2>&1; then
          proxy off || true
        fi
        ;;
      *)
        echo "Usage: $0 <manual|none> [proxy_ip proxy_port ignore_hosts]" >&2
        exit 2
        ;;
    esac
  '';
in
{
  security.wrappers.sing-box = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin,cap_net_bind_service+ep";
    source = "${pkgs.sing-box}/bin/sing-box";
  };

  system.activationScripts.v2rayn-sing-box-core.text = ''
    ${pkgs.coreutils}/bin/install -d -o cloudygirl -g users -m 0755 /home/cloudygirl/.local/share/v2rayN/bin/sing_box
    ${pkgs.coreutils}/bin/ln -sfn /run/wrappers/bin/sing-box /home/cloudygirl/.local/share/v2rayN/bin/sing_box/sing-box
    ${pkgs.coreutils}/bin/chown -h cloudygirl:users /home/cloudygirl/.local/share/v2rayN/bin/sing_box/sing-box
  '';

  system.activationScripts.v2rayn-system-proxy-script.text = ''
    ${pkgs.coreutils}/bin/install -d -o cloudygirl -g users -m 0755 /home/cloudygirl/.local/share/v2rayN/binConfigs
    ${pkgs.coreutils}/bin/install -o cloudygirl -g users -m 0755 ${v2raynSystemProxyScript} /home/cloudygirl/.local/share/v2rayN/binConfigs/proxy_set_linux_sh.sh
  '';

  environment.systemPackages = [ proxy ];
}
