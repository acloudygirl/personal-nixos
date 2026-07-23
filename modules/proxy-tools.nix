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

    # --- Chrome managed policy ---
    ${pkgs.coreutils}/bin/install -d -m 0755 /run/nix-proxy
    ${pkgs.coreutils}/bin/touch /run/nix-proxy/enabled
    ${pkgs.coreutils}/bin/install -d -m 0755 /etc/opt/chrome/policies/managed
    ${pkgs.coreutils}/bin/ln -sfn ${chromeProxyPolicy} /etc/opt/chrome/policies/managed/proxy.json
    echo "Chrome proxy policy enabled"

    # --- Desktop proxy (KDE / GNOME) ---
    target_user="''${SUDO_USER:-}"
    if [ -z "$target_user" ] && [ -n "''${PKEXEC_UID:-}" ]; then
      target_user="$(${pkgs.coreutils}/bin/id -nu "$PKEXEC_UID" 2>/dev/null || true)"
    fi
    target_user="''${target_user:-cloudygirl}"
    target_home="$(${pkgs.coreutils}/bin/getent passwd "$target_user" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d: -f6)"
    target_home="''${target_home:-/home/$target_user}"

    proxy_host="''${proxy_url#*://}"; proxy_host="''${proxy_host%%:*}"
    proxy_port="''${proxy_url##*:}"
    ignore_hosts="localhost,127.0.0.0/8,::1"

    # KDE — write directly as root (bypasses sudo/PATH issues)
    kioslaverc="$target_home/.config/kioslaverc"
    if [ -f "$kioslaverc" ]; then
      ${pkgs.gnused}/bin/sed -i 's/^ProxyType=.*/ProxyType=1/' "$kioslaverc"
      # Ensure proxy URL lines exist
      for kv in \
        "httpProxy=http://$proxy_host:$proxy_port" \
        "httpsProxy=http://$proxy_host:$proxy_port" \
        "ftpProxy=http://$proxy_host:$proxy_port" \
        "socksProxy=socks://$proxy_host:$proxy_port" \
        "NoProxyFor=$ignore_hosts"
      do
        key="''${kv%%=*}"
        if ${pkgs.gnugrep}/bin/grep -q "^$key=" "$kioslaverc" 2>/dev/null; then
          ${pkgs.gnused}/bin/sed -i "s|^$key=.*|$kv|" "$kioslaverc"
        else
          echo "$kv" >> "$kioslaverc"
        fi
      done
      echo "KDE proxy enabled"
    fi

    # Remove v2rayN lock so it can manage proxy again
    ${pkgs.coreutils}/bin/rm -f "$target_home/.config/v2rayn/proxy-locked-off"
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

    # --- Chrome managed policy ---
    ${pkgs.coreutils}/bin/rm -f /run/nix-proxy/enabled
    ${pkgs.coreutils}/bin/rm -f /etc/opt/chrome/policies/managed/proxy.json
    echo "Chrome proxy policy disabled"

    # --- Desktop proxy (KDE / GNOME) ---
    target_user="''${SUDO_USER:-}"
    if [ -z "$target_user" ] && [ -n "''${PKEXEC_UID:-}" ]; then
      target_user="$(${pkgs.coreutils}/bin/id -nu "$PKEXEC_UID" 2>/dev/null || true)"
    fi
    target_user="''${target_user:-cloudygirl}"
    target_home="$(${pkgs.coreutils}/bin/getent passwd "$target_user" 2>/dev/null | ${pkgs.coreutils}/bin/cut -d: -f6)"
    target_home="''${target_home:-/home/$target_user}"

    # KDE — write directly as root (bypasses sudo/PATH issues)
    kioslaverc="$target_home/.config/kioslaverc"
    if [ -f "$kioslaverc" ]; then
      ${pkgs.gnused}/bin/sed -i 's/^ProxyType=.*/ProxyType=0/' "$kioslaverc"
      echo "KDE proxy disabled"
    fi

    # Prevent v2rayN from re-enabling proxy
    ${pkgs.coreutils}/bin/mkdir -p "$target_home/.config/v2rayn"
    ${pkgs.coreutils}/bin/touch "$target_home/.config/v2rayn/proxy-locked-off"
    echo "v2rayN proxy lock: active"
  '';

  nixProxyStatus = pkgs.writeShellScriptBin "nix-proxy-status" ''
    set -euo pipefail

    dropin=/run/systemd/system/nix-daemon.service.d/10-v2rayn-proxy.conf

    echo "=== nix-daemon proxy ==="
    if [ -f "$dropin" ]; then
      echo "  status: enabled"
      ${pkgs.gnused}/bin/sed -n 's/^Environment="\([^"]*\)"$/  \1/p' "$dropin"
    else
      echo "  status: disabled"
    fi

    echo "=== Chrome proxy policy ==="
    chrome_policy=/etc/opt/chrome/policies/managed/proxy.json
    if [ -f "$chrome_policy" ] && [ -f /run/nix-proxy/enabled ]; then
      echo "  status: enabled"
    else
      echo "  status: disabled"
    fi

    echo "=== KDE desktop proxy ==="
    kde_config=""
    if command -v kwriteconfig6 >/dev/null 2>&1; then
      kde_config="kwriteconfig6"
    elif command -v kwriteconfig5 >/dev/null 2>&1; then
      kde_config="kwriteconfig5"
    fi
    if [ -n "$kde_config" ]; then
      proxy_type="$("$kde_config" --file kioslaverc --group "Proxy Settings" --key ProxyType 2>/dev/null || true)"
      if [ "''${proxy_type:-}" = "1" ]; then
        echo "  status: enabled"
        echo "  httpProxy: $("$kde_config" --file kioslaverc --group "Proxy Settings" --key httpProxy 2>/dev/null || true)"
        echo "  socksProxy: $("$kde_config" --file kioslaverc --group "Proxy Settings" --key socksProxy 2>/dev/null || true)"
      else
        echo "  status: disabled (ProxyType=''${proxy_type:-})"
      fi
    else
      echo "  status: unknown (kwriteconfig not found)"
    fi

    echo "=== v2rayN local proxy ==="
    if ${pkgs.iproute2}/bin/ss -ltn | ${pkgs.gnugrep}/bin/grep -q '127\.0\.0\.1:10808'; then
      echo "  listening on 127.0.0.1:10808"
    else
      echo "  not listening on 127.0.0.1:10808"
    fi
  '';

  v2raynSystemProxyScript = pkgs.writeShellScript "v2rayn-system-proxy-linux" ''
    set -u

    mode="''${1:-}"
    proxy_ip="''${2:-127.0.0.1}"
    proxy_port="''${3:-10808}"
    ignore_hosts="''${4:-localhost,127.0.0.0/8,::1}"

    # Respect nix-proxy-off lock — skip if proxy was explicitly disabled
    lock_file="''${HOME:-/home/cloudygirl}/.config/v2rayn/proxy-locked-off"
    if [ -f "$lock_file" ]; then
      exit 0
    fi

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

  chromeProxyPolicy = pkgs.writeText "chrome-proxy-policy.json" (builtins.toJSON {
    ProxyMode = "fixed_servers";
    ProxyServer = "socks5://127.0.0.1:10808";
    ProxyBypassList = "<-loopback>";
  });
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
