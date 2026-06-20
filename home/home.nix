{ pkgs,...}:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.cloudygirl = _: {
      home.stateVersion = "26.05";

      home.packages = with pkgs; [
        noctalia-shell
        xwayland-satellite
        kitty
      ];
    };
    backupFileExtension = ".bak";
  };
}
