{ pkgs, ... }:
{
    virtualisation.docker.enable = true;
    users.users.cloudygirl.extraGroups = [ "docker" ];
    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.autoPrune.dates = "weekly";

    virtualisation.docker.daemon.settings = {
        registry-mirrors = [
            "https://hub.rat.dev"
            "https://docker.1ms.run"
            "https://docker.m.daocloud.io"
        ];
    };
}
