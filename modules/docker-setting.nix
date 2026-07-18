{ pkgs, ... }:
{
    virtualisation.docker.enable = true;
    users.users.cloudygirl.extraGroups = [ "docker" ];

}