{ pkgs, ... }:

{
  programs.google-chrome = {
    enable = true;
    commandLineArgs = [
      "--enable-experimental-web-platform-features"
      "--enable-features=AcceleratedVideoDecodeLinuxGL"
    ];
  };

  programs.firefox = {
    enable = true;
    profiles.main = {
      id = 0;
      isDefault = true;
      settings = {
        "sidebar.verticalTabs" = true;
        "browser.search.openintab" = true;
        "browser.urlbar.openintab" = true;
      };
    };
  };

  xdg.configFile."niri/config.kdl" = {
    source = ./config/niri/config.kdl;
    force = true;
  };

  xdg.configFile."kitty/kitty.conf" = {
    source = ./config/kitty/kitty.conf;
    force = true;
  };
}
