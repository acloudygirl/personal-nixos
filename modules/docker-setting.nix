{ pkgs, ... }:
{
    virtualisation.docker.enable = true;         #启用docker
    users.users.cloudygirl.extraGroups = [ "docker" ];  #加入权限组
    virtualisation.docker.autoPrune.enable = true;   #docker自动清理垃圾功能
    virtualisation.docker.autoPrune.dates = "weekly"; #每周清理垃圾

    virtualisation.docker.daemon.settings = { #启用国内镜像源
        registry-mirrors = [
        "https://docker.m.daocloud.io"
        ];
    };
}