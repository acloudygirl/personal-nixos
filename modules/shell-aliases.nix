{ ... }:
let
  aliases = import ./shell-aliases-data.nix;
in
#常用命令简化
{
  environment.shellAliases = aliases;
}
