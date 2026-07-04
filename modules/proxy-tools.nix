{ pkgs, ... }:

let
  nixProxyOn = pkgs.writeShellScriptBin "nix-proxy-on" ''
    set -euo pipefail

    if [ "$(${pkgs.coreutils}/bin/id -u)" -ne 0 ]; then
      if [ -x /run/wrappers/bin/pkexec ] && { [ -n "''${WAYLAND_DISPLAY:-}" ] || [ -n "''${DISPLAY:-}" ]; }; then
        exec /run/wrappers/bin/pkexec "$0" "$@"
      fi
      exec ${pkgs.sudo}/bin/sudo "$0" "$@"
    fi

    proxy_url="''${1:-http://127.0.0.1:10808}"
    no_proxy="localhost,127.0.0.1,::1"
    dropin_dir=/run/systemd/system/nix-daemon.service.d
    dropin="$dropin_dir/10-v2rayn-proxy.conf"

    ${pkgs.coreutils}/bin/install -d -m 0755 "$dropin_dir"
    ${pkgs.coreutils}/bin/cat > "$dropin" <<EOF
[Service]
Environment="http_proxy=$proxy_url"
Environment="https_proxy=$proxy_url"
Environment="HTTP_PROXY=$proxy_url"
Environment="HTTPS_PROXY=$proxy_url"
Environment="no_proxy=$no_proxy"
Environment="NO_PROXY=$no_proxy"
EOF

    ${pkgs.systemd}/bin/systemctl daemon-reload
    ${pkgs.systemd}/bin/systemctl restart nix-daemon.service
    echo "nix-daemon proxy enabled: $proxy_url"
  '';

  nixProxyOff = pkgs.writeShellScriptBin "nix-proxy-off" ''
    set -euo pipefail

    if [ "$(${pkgs.coreutils}/bin/id -u)" -ne 0 ]; then
      if [ -x /run/wrappers/bin/pkexec ] && { [ -n "''${WAYLAND_DISPLAY:-}" ] || [ -n "''${DISPLAY:-}" ]; }; then
        exec /run/wrappers/bin/pkexec "$0" "$@"
      fi
      exec ${pkgs.sudo}/bin/sudo "$0" "$@"
    fi

    dropin_dir=/run/systemd/system/nix-daemon.service.d
    dropin="$dropin_dir/10-v2rayn-proxy.conf"

    ${pkgs.coreutils}/bin/rm -f "$dropin"
    ${pkgs.coreutils}/bin/rmdir --ignore-fail-on-non-empty "$dropin_dir" 2>/dev/null || true
    ${pkgs.systemd}/bin/systemctl daemon-reload
    ${pkgs.systemd}/bin/systemctl restart nix-daemon.service
    echo "nix-daemon proxy disabled"
  '';

  nixProxyStatus = pkgs.writeShellScriptBin "nix-proxy-status" ''
    set -euo pipefail

    dropin=/run/systemd/system/nix-daemon.service.d/10-v2rayn-proxy.conf

    if [ -f "$dropin" ]; then
      echo "nix-daemon proxy: enabled"
      ${pkgs.gnused}/bin/sed -n 's/^Environment="\([^"]*\)"$/  \1/p' "$dropin"
    else
      echo "nix-daemon proxy: disabled"
    fi

    if ${pkgs.iproute2}/bin/ss -ltn | ${pkgs.gnugrep}/bin/grep -q '127\.0\.0\.1:10808'; then
      echo "v2rayN local proxy: listening on 127.0.0.1:10808"
    else
      echo "v2rayN local proxy: not listening on 127.0.0.1:10808"
    fi
  '';

  v2raynSystemProxyScript = pkgs.writeShellScript "v2rayn-system-proxy-linux" ''
    set -u

    mode="''${1:-}"
    proxy_ip="''${2:-127.0.0.1}"
    proxy_port="''${3:-10808}"
    ignore_hosts="''${4:-localhost,127.0.0.0/8,::1}"

    notify_kio() {
      if ${pkgs.dbus}/bin/dbus-send --type=signal /KIO/Scheduler org.kde.KIO.Scheduler.reparseSlaveConfiguration string:"" >/dev/null 2>&1; then
        return 0
      fi
      return 0
    }

    kwriteconfig_cmd() {
      if command -v kwriteconfig6 >/dev/null 2>&1; then
        command -v kwriteconfig6
        return 0
      fi
      if command -v kwriteconfig5 >/dev/null 2>&1; then
        command -v kwriteconfig5
        return 0
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

      notify_kio
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
        if command -v nix-proxy-on >/dev/null 2>&1; then
          nix-proxy-on "http://$proxy_ip:$proxy_port" || echo "nix-daemon proxy switch failed" >&2
        fi
        ;;
      none)
        set_kde_proxy
        set_gnome_proxy
        if command -v nix-proxy-off >/dev/null 2>&1; then
          nix-proxy-off || echo "nix-daemon proxy switch failed" >&2
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

  environment.systemPackages = [
    nixProxyOn
    nixProxyOff
    nixProxyStatus
  ];

  system.activationScripts.v2rayn-system-proxy-script.text = ''
    ${pkgs.coreutils}/bin/install -d -o cloudygirl -g users -m 0755 /home/cloudygirl/.local/share/v2rayN/binConfigs
    ${pkgs.coreutils}/bin/install -o cloudygirl -g users -m 0755 ${v2raynSystemProxyScript} /home/cloudygirl/.local/share/v2rayN/binConfigs/proxy_set_linux_sh.sh
  '';
}
