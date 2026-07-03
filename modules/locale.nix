{ pkgs, ... }:

{
  # 区域设置和输入法
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.addons = with pkgs; [ qt6Packages.fcitx5-chinese-addons ];
  };

  time.timeZone = "Asia/Shanghai";
}
