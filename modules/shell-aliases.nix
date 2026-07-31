{ ... }:
#常用命令简化
{
  environment.shellAliases = {
    nixrs = "git -C /home/cloudygirl/nixos add -A && nh os switch";
    ncg = "sudo nix-collect-garbage -d";
  };
}
