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
- `configuration.nix`：系统主配置，放启动器、网络、桌面环境、电源、系统包、用户等机器级设置。
- `hardware-configuration.nix`：硬件扫描生成的配置，主要是文件系统、启动设备、内核模块等。

## 独立模块

- `fonts.nix`：系统字体配置。
- `sddm-theme.nix`：SDDM 登录界面主题、登录背景、主题依赖和主题包配置。
- `software/default.nix`：用户软件和 Home Manager 配置入口。
- `software/default.nix` 里的 `xdg.mimeApps`：默认打开方式配置，例如 `.nix`/文本用 VS Code，`.md` 用 MarkText，`.pdf` 用 Sioyek。
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
