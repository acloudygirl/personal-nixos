{ pkgs, ... }:
{
    virtualisation.docker.enable = true;
    users.users.cloudygirl.extraGroups = [ "docker" ];
    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.autoPrune.dates = "weekly";

    virtualisation.docker.daemon.settings = {
        proxies = {
            http-proxy = "http://127.0.0.1:7897";
            https-proxy = "http://127.0.0.1:7897";
            no-proxy = "localhost,127.0.0.1";
        };
    };
}
