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

  # Rime 输入法配置
  xdg.dataFile."fcitx5/rime/default.custom.yaml" = {
    source = ./config/fcitx5/rime/default.custom.yaml;
    force = true;
  };
  xdg.dataFile."fcitx5/rime/luna_pinyin.custom.yaml" = {
    source = ./config/fcitx5/rime/luna_pinyin.custom.yaml;
    force = true;
  };
  xdg.dataFile."fcitx5/rime/luna_pinyin.custom.dict.yaml" = {
    source = ./config/fcitx5/rime/luna_pinyin.custom.dict.yaml;
    force = true;
  };
  xdg.dataFile."fcitx5/rime/fcitx5.custom.yaml" = {
    source = ./config/fcitx5/rime/fcitx5.custom.yaml;
    force = true;
  };
  xdg.dataFile."fcitx5/rime/emoji.schema.yaml" = {
    source = ./config/fcitx5/rime/emoji.schema.yaml;
    force = true;
  };
  xdg.dataFile."fcitx5/rime/emoji.dict.yaml" = {
    source = ./config/fcitx5/rime/emoji.dict.yaml;
    force = true;
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
