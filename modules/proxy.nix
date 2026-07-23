{ pkgs, ... }:
let
  proxyPort = "10808";

  proxyToggle = pkgs.writeShellScriptBin "proxy" ''
    set -euo pipefail

    if [ "$(id -u)" -ne 0 ]; then
      exec sudo "$0" "$@"
    fi

    DROPIN_DIR=/run/systemd/system/nix-daemon.service.d
    DROPIN="$DROPIN_DIR/10-proxy.conf"
    PROXY_ENV=/etc/proxy.env

    case "''${1:-}" in
      on)
        mkdir -p "$DROPIN_DIR"
        cat > "$DROPIN" <<'EOF'
[Service]
Environment="http_proxy=http://127.0.0.1:${proxyPort}"
Environment="https_proxy=http://127.0.0.1:${proxyPort}"
Environment="HTTP_PROXY=http://127.0.0.1:${proxyPort}"
Environment="HTTPS_PROXY=http://127.0.0.1:${proxyPort}"
Environment="no_proxy=localhost,127.0.0.1,::1"
Environment="NO_PROXY=localhost,127.0.0.1,::1"
EOF
        systemctl daemon-reload
        systemctl restart nix-daemon.service

        cat > "$PROXY_ENV" <<EOF
export http_proxy=http://127.0.0.1:${proxyPort}
export https_proxy=http://127.0.0.1:${proxyPort}
export HTTP_PROXY=http://127.0.0.1:${proxyPort}
export HTTPS_PROXY=http://127.0.0.1:${proxyPort}
export no_proxy=localhost,127.0.0.1,::1
export NO_PROXY=localhost,127.0.0.1,::1
EOF
        echo "proxy on — done"
        echo "  run: source $PROXY_ENV   (or open new terminal)"
        ;;

      off)
        rm -f "$DROPIN"
        rmdir --ignore-fail-on-non-empty "$DROPIN_DIR" 2>/dev/null || true
        systemctl daemon-reload
        systemctl restart nix-daemon.service

        rm -f "$PROXY_ENV"
        echo "proxy off — done"
        echo "  run: unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY no_proxy NO_PROXY"
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

  # root's .bashrc also sources proxy.env so "su -" and login shells get it
  programs.bash.interactiveShellInit = ''
    [ -f /etc/proxy.env ] && source /etc/proxy.env
  '';
}
