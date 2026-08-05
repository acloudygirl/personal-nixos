{ pkgs, ... }:

{
  # 区域设置和输入法
  i18n.defaultLocale = "zh_CN.UTF-8";

  i18n.inputMethod = {
    type = "fcitx5";
    enable = true;
    fcitx5.waylandFrontend = false;
    fcitx5.addons = with pkgs; [
      fcitx5-rime
      qt6Packages.fcitx5-chinese-addons
    ];
  };

  # 为 X11/XWayland 应用（如 QQ）设置输入法环境变量
  environment.sessionVariables = {
    QT_IM_MODULE = "fcitx";
    GTK_IM_MODULE = "fcitx";
  };

  time.timeZone = "Asia/Shanghai";
}
