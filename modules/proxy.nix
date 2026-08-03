{ pkgs, ... }:
let
  proxyPort = "10808";

  proxyToggle = pkgs.writeShellScriptBin "proxy" ''
    set -euo pipefail
    ORIG_USER="''${SUDO_USER:-$(id -un)}"

    if [ "$(id -u)" -ne 0 ]; then
      exec sudo "$0" "$@"
    fi

    DROPIN_DIR=/run/systemd/system/nix-daemon.service.d
    DROPIN="$DROPIN_DIR/10-proxy.conf"
    PROXY_ENV=/etc/proxy.env
    PROXY_IGNORE="localhost,127.0.0.0/8,::1,api.noctalia.dev"

    find_kwriteconfig() {
      if command -v kwriteconfig6 >/dev/null 2>&1; then
        command -v kwriteconfig6
      elif command -v kwriteconfig5 >/dev/null 2>&1; then
        command -v kwriteconfig5
      else
        echo ""
      fi
    }

    set_kde_manual() {
      local kc
      kc="$(find_kwriteconfig)"
      [ -n "$kc" ] || return 0
      # 普通用户
      sudo -u "$ORIG_USER" "$kc" --file kioslaverc --group "Proxy Settings" --key ProxyType 1
      sudo -u "$ORIG_USER" "$kc" --file kioslaverc --group "Proxy Settings" --key httpProxy "http://127.0.0.1:${proxyPort}"
      sudo -u "$ORIG_USER" "$kc" --file kioslaverc --group "Proxy Settings" --key httpsProxy "http://127.0.0.1:${proxyPort}"
      sudo -u "$ORIG_USER" "$kc" --file kioslaverc --group "Proxy Settings" --key ftpProxy "http://127.0.0.1:${proxyPort}"
      sudo -u "$ORIG_USER" "$kc" --file kioslaverc --group "Proxy Settings" --key socksProxy "socks://127.0.0.1:${proxyPort}"
      sudo -u "$ORIG_USER" "$kc" --file kioslaverc --group "Proxy Settings" --key NoProxyFor "$PROXY_IGNORE"
      sudo -u "$ORIG_USER" dbus-send --type=signal /KIO/Scheduler org.kde.KIO.Scheduler.reparseSlaveConfiguration string:"" >/dev/null 2>&1 || true
      # root
      "$kc" --file kioslaverc --group "Proxy Settings" --key ProxyType 1
      "$kc" --file kioslaverc --group "Proxy Settings" --key httpProxy "http://127.0.0.1:${proxyPort}"
      "$kc" --file kioslaverc --group "Proxy Settings" --key httpsProxy "http://127.0.0.1:${proxyPort}"
      "$kc" --file kioslaverc --group "Proxy Settings" --key ftpProxy "http://127.0.0.1:${proxyPort}"
      "$kc" --file kioslaverc --group "Proxy Settings" --key socksProxy "socks://127.0.0.1:${proxyPort}"
      "$kc" --file kioslaverc --group "Proxy Settings" --key NoProxyFor "$PROXY_IGNORE"
    }

    set_kde_direct() {
      local kc
      kc="$(find_kwriteconfig)"
      [ -n "$kc" ] || return 0
      sudo -u "$ORIG_USER" "$kc" --file kioslaverc --group "Proxy Settings" --key ProxyType 0
      sudo -u "$ORIG_USER" dbus-send --type=signal /KIO/Scheduler org.kde.KIO.Scheduler.reparseSlaveConfiguration string:"" >/dev/null 2>&1 || true
      "$kc" --file kioslaverc --group "Proxy Settings" --key ProxyType 0
    }

    case "''${1:-}" in
      on)
        mkdir -p "$DROPIN_DIR"
        cat > "$DROPIN" <<'EOF'
[Service]
Environment="http_proxy=http://127.0.0.1:${proxyPort}"
Environment="https_proxy=http://127.0.0.1:${proxyPort}"
Environment="HTTP_PROXY=http://127.0.0.1:${proxyPort}"
Environment="HTTPS_PROXY=http://127.0.0.1:${proxyPort}"
Environment="no_proxy=localhost,127.0.0.1,::1,api.noctalia.dev"
Environment="NO_PROXY=localhost,127.0.0.1,::1,api.noctalia.dev"
EOF
        systemctl daemon-reload
        systemctl restart nix-daemon.service

        cat > "$PROXY_ENV" <<EOF
export http_proxy=http://127.0.0.1:${proxyPort}
export https_proxy=http://127.0.0.1:${proxyPort}
export HTTP_PROXY=http://127.0.0.1:${proxyPort}
export HTTPS_PROXY=http://127.0.0.1:${proxyPort}
export no_proxy=localhost,127.0.0.1,::1,api.noctalia.dev
export NO_PROXY=localhost,127.0.0.1,::1,api.noctalia.dev
EOF
        set_kde_manual
        echo "proxy on — done"
        ;;

      off)
        rm -f "$DROPIN"
        rmdir --ignore-fail-on-non-empty "$DROPIN_DIR" 2>/dev/null || true
        systemctl daemon-reload
        systemctl restart nix-daemon.service

        rm -f "$PROXY_ENV"
        set_kde_direct
        echo "proxy off — done"
        ;;

      status)
        if [ -f "$DROPIN" ]; then
          echo "nix-daemon proxy: ON"
        else
          echo "nix-daemon proxy: OFF"
        fi
        if [ -f "$PROXY_ENV" ]; then
          echo "shell proxy file:  ON  ($PROXY_ENV)"
        else
          echo "shell proxy file:  OFF"
        fi
        echo "env: HTTP_PROXY=''${HTTP_PROXY:-<unset>}"
        ;;

      *)
        echo "Usage: proxy {on|off|status}" >&2
        exit 1
        ;;
    esac
  '';
in
{
  environment.systemPackages = [ proxyToggle ];

  # sudo preserves proxy env vars, so "sudo cmd" inherits whatever
  # HTTP_PROXY the calling shell currently has
  security.sudo.extraConfig = ''
    Defaults env_keep += "http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY"
  '';

  # bash 兜底：login shell 加载 proxy
  programs.bash.interactiveShellInit = ''
    [ -f /etc/proxy.env ] && source /etc/proxy.env
  '';
}
