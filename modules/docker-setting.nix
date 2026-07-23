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

    systemd.services.docker.environment = {
        HTTP_PROXY = "http://127.0.0.1:10808";
        HTTPS_PROXY = "http://127.0.0.1:10808";
        http_proxy = "http://127.0.0.1:10808";
        https_proxy = "http://127.0.0.1:10808";
        NO_PROXY = "localhost,127.0.0.1,::1";
        no_proxy = "localhost,127.0.0.1,::1";
    };
}
