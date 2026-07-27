{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prismlauncher  # Minecraft 启动器
  ];
}
