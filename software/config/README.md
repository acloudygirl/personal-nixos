# 用户软件配置

这里放适合上传的 `~/.config` 配置快照。

当前已收进来的内容包括：

- `niri/`：Niri 窗口管理器配置，已经在 `software/default.nix` 中映射到 `~/.config/niri/config.kdl`。
- `noctalia/`：Noctalia Shell 的主题和行为设置。
- `fcitx5/`：输入法配置，已排除生成缓存 `conf/cached_layouts`。
- `glow/`：Glow Markdown 阅读器配置。
- `sioyek/`：Sioyek PDF 阅读器用户偏好。
- `gtk-3.0/`、`gtk-4.0/`、`gtkrc`、`gtkrc-2.0`：GTK 外观配置。
- `fontconfig/`、`xsettingsd/`：字体和 XSettings 配置。
- 根目录下的 KDE/Qt/桌面偏好文件：例如 `kdeglobals`、`kglobalshortcutsrc`、`kioslaverc`、`mimeapps.list`。

刻意没有收进来：

- 浏览器目录，如 `google-chrome/`、`chromium/`、`BraveSoftware/`。
- 即时通讯和 Electron 应用状态目录，如 `QQ/`、`Code/`、`Codex/`。
- Cookie、数据库、缓存、锁文件、会话历史、同步状态。
- VS Code `Code/User/settings.json`，因为当前文件里包含 API key。

如果要让某个配置由 Home Manager 强制接管，再在 `software/default.nix` 里添加对应的 `xdg.configFile`。频繁由应用写入的配置不要急着映射，否则应用可能无法保存设置。
