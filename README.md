# NixOS 配置说明
**如下是AI写的**


这个仓库是当前机器的 NixOS flake 配置，目标主机是 `nixos`。常用检查命令：

```bash
nixos-rebuild dry-build --flake /home/cloudygirl/nixos#nixos
```

应用配置需要 root 权限：

```bash
sudo nixos-rebuild switch --flake /home/cloudygirl/nixos#nixos
```

## 入口文件

- `flake.nix`：flake 入口，声明 `nixpkgs`、`home-manager` 输入，并组装 `nixosConfigurations.nixos`。
- `flake.lock`：锁定输入版本，保证构建结果可复现。
- `configuration.nix`：系统主入口，只保留模块导入和 `system.stateVersion`。
- `hardware-configuration.nix`：硬件扫描生成的配置，主要是文件系统、启动设备、内核模块等。

## 独立模块

- `modules/boot.nix`：GRUB/EFI 启动加载器配置。
- `modules/desktop.nix`：Xwayland、Plasma、Niri、SDDM 启用项，以及 Flatpak/Flathub 配置。
- `modules/hardware-tweaks.nix`：内核参数、华硕键盘背光、蓝牙等硬件相关调整。
- `modules/locale.nix`：中文区域设置、时区和 Fcitx5 输入法。
- `modules/networking.nix`：主机名、NetworkManager 和网络托盘。
- `modules/nix-settings.nix`：Nix flakes、二进制缓存和 unfree 包策略。
- `modules/packages.nix`：全系统命令行工具、桌面应用、开发工具链和 `mdpdf` 命令。
- `modules/power.nix`：TLP、电源管理和安静 CPU 配置。
- `modules/proxy-tools.nix`：sing-box 权限包装器和 v2rayN sing-box 核心链接。
- `modules/users.nix`：本机用户配置。
- `fonts.nix`：系统字体配置。
- `sddm-theme.nix`：SDDM 登录界面主题、登录背景、主题依赖和主题包配置。
- `software/default.nix`：用户软件和 Home Manager 配置入口。
- `software/default.nix` 里的 `xdg.mimeApps`：默认打开方式配置，例如文件夹用 Dolphin，图片用 Gwenview，视频用 Haruna，音频用 Elisa，压缩包用 Ark，`.nix`/文本用 VS Code，`.md` 用 MarkText，`.pdf` 用 Sioyek。
- `notes/`：Pandoc + XeLaTeX 中文 PDF 笔记模板。

## 资源和软件配置

- `assets/login-bg.jpg`：SDDM 登录背景图，由 `sddm-theme.nix` 打包进主题。
- `software/config/`：适合上传的用户软件配置快照。
- `software/config/niri/config.kdl`：Niri 配置源文件，由 Home Manager 部署到 `~/.config/niri/config.kdl`。

以后新增应用自己的配置文件时，优先放到 `software/config/<app>/`，再在 `software/default.nix` 里用 `xdg.configFile` 映射到 `~/.config/<app>/...`。

不是所有 `software/config/` 里的文件都应该立刻用 Home Manager 强制接管。像 KDE、Noctalia、Fcitx5 这类应用会自己写配置，先作为可上传快照保存；确定要声明式管理后，再单独加 `xdg.configFile` 映射。

## 清理规则

- 不提交 `result` 这类 `nix build` 生成的结果链接。
- 不保留 `*.bak` 备份文件；需要历史版本时用 Git。
- 不提交浏览器、QQ、VS Code/Codex 缓存、Cookie、数据库、会话历史和 API key。
- 系统级设置放 `configuration.nix` 或独立 `.nix` 模块。
- 用户软件包和 `~/.config` 下的应用配置放 `software/`。
