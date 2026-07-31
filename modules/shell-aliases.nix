{ ... }:
#常用命令简化
{
  environment.shellAliases = {
    cdnixos = "cd /home/cloudygirl/nixos";
    nixrs = "git -C /home/cloudygirl/nixos add -A && sudo nixos-rebuild switch --flake /home/cloudygirl/nixos";  #git add & nixos-rebuild switch --flake ...,flake不认未跟踪的改动
    ncg = "sudo nix-collect-garbage -d";
  };
  #设置重启指定gui程序
  programs.bash.interactiveShellInit = ''
    restart() {
      if [ $# -eq 0 ]; then
        echo "用法: restart <进程名> [参数...]"
        return 1
      fi
      pkill -f "$1"
      sleep 1
      nohup "$@" >/dev/null 2>&1 &
    }
  '';
}
