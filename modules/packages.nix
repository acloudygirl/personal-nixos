{ pkgs, ... }:

let
  # Markdown 转 PDF
  # .md文件转化为.pdf命令缩减：mdpdf note.md [output.pdf]
  mdpdf = pkgs.writeShellScriptBin "mdpdf" ''
    set -euo pipefail

    if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
      echo "Usage: mdpdf INPUT.md [OUTPUT.pdf]" >&2
      exit 2
    fi

    input="$(${pkgs.coreutils}/bin/realpath "$1")"
    if [ "$#" -eq 2 ]; then
      output="$(${pkgs.coreutils}/bin/realpath -m "$2")"
    else
      output="''${input%.*}.pdf"
    fi

    workdir="$(${pkgs.coreutils}/bin/dirname "$input")"
    filename="$(${pkgs.coreutils}/bin/basename "$input")"

    cd "$workdir"
    exec ${pkgs.pandoc}/bin/pandoc "$filename" \
      -d ${../notes/template/pandoc.yaml} \
      -o "$output"
  '';
in

{
  # 全系统命令行工具、桌面应用和开发工具链
  environment.systemPackages = with pkgs; [
    tree #linux-shell tree
    file #linux-shell filew
    bitwarden-cli #密码库
    jq
    fzf

    fastfetch
    # 版本控制
    git
    gnumake
    tmux
    # md-pdf转换命令
    mdpdf
    fastfetch
    #梯子
    v2rayn
    sing-box

    # Python
    python3
    uv
    ruff
    pyright

    # C 和 C++
    gcc
    clang
    clang-tools
    cmake
    ninja
    gdb
    lldb

    # Rust
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    # 文件管理器
    thunar
    thunar-volman
    gvfs

    #软件提权工具
    lxqt.lxqt-policykit

    # 蓝牙工具
    bluez
    bluez-tools
    kdePackages.bluedevil

    # 桌面应用
    #kdePackages.konsole    #KED命令行
    kdePackages.polkit-kde-agent-1
    google-chrome
    home-manager
    nodejs_22
    vscode
    qq
    wechat
    wpsoffice-cn
    helix #.nix文件编辑器，nano替代
    kdePackages.gwenview # 图片查看器
    kdePackages.elisa # 音乐播放器
    marktext # Markdown 阅读器
    sioyek # PDF 阅读器
    pandoc # Markdown 转 PDF
    texliveFull #md转pdf渲染库
    codex
    go-musicfox #网易云音乐
    opencode #AI
    opencode-desktop
    mcp-nixos
    github-mcp-server #GitHub MCP 服务
    wl-clipboard #Wayland 剪贴板工具（noctalia 依赖）
    cliphist #剪贴板历史（noctalia 依赖）
    qalculate-qt #科学计算器
    #压缩软件
    kdePackages.ark
    p7zip
    unzip
    zip
    unrar
    #视频播放
    mpv
    vlc
    celluloid  # GTK 前端
    haruna # 视频播放器
  ];
}
