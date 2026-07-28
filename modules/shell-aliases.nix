{ ... }:
#常用命令简化
{
  environment.shellAliases = {
    cdnixos = "cd /home/cloudygirl/nixos";
    nixrs = "git -C /home/cloudygirl/nixos add -A && sudo nixos-rebuild switch --flake /home/cloudygirl/nixos";  #git add & nixos-rebuild switch --flake ...,flake不认未跟踪的改动
    ncg = "sudo nix-collect-garbage -d";
  };
}
