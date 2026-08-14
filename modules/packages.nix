{ pkgs, ... }:

let
  # Markdown 转 PDF
  # 用法：mdpdf note.md [output.pdf]
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

  # 视频自动生成字幕
  # 用法：autosub 视频文件.mp4 [语言] [模型]
  # 语言默认 zh（中文），可选 en/ja 等
  # 模型默认 small，可选 tiny/base/small/medium/large-v3
  autosub = pkgs.writeShellScriptBin "autosub" ''
    set -euo pipefail

    if [ "$#" -lt 1 ]; then
      echo "Usage: autosub VIDEO [LANG] [MODEL]" >&2
      echo "  LANG:   zh(默认), en, ja, ko, ..." >&2
      echo "  MODEL:  tiny, base, small(默认), medium, large-v3" >&2
      exit 2
    fi

    input="$(${pkgs.coreutils}/bin/realpath "$1")"
    lang="''${2:-zh}"
    model="''${3:-small}"

    model_dir="$HOME/.cache/whisper-cpp"
    model_file="$model_dir/ggml-$model.bin"

    if [ ! -f "$model_file" ]; then
      echo "Downloading model: $model ..." >&2
      ${pkgs.coreutils}/bin/mkdir -p "$model_dir"
      ${pkgs.wget}/bin/wget -q -O "$model_file" \
        "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-$model.bin"
    fi

    workdir="$(${pkgs.coreutils}/bin/dirname "$input")"
    filename="$(${pkgs.coreutils}/bin/basename "$input")"
    name="''${filename%.*}"

    tmpdir="$(${pkgs.coreutils}/bin/mktemp -d)"
    ${pkgs.ffmpeg}/bin/ffmpeg -i "$input" -vn -acodec pcm_s16le -ar 16000 -ac 1 "$tmpdir/audio.wav" -y -loglevel error

    echo "Generating subtitles (model: $model, lang: $lang) ..." >&2
    ${pkgs.whisper-cpp}/bin/whisper-cpp -m "$model_file" -f "$tmpdir/audio.wav" -l "$lang" -osrt -o "$tmpdir"

    ${pkgs.coreutils}/bin/cp "$tmpdir/audio.srt" "$workdir/$name.srt"
    ${pkgs.coreutils}/bin/rm -rf "$tmpdir"

    echo "Done: $workdir/$name.srt" >&2
  '';
in

{
  environment.systemPackages = with pkgs; [
    # ── 终端工具 ──
    zoxide
    nh
    fd
    fzf
    ripgrep
    direnv
    fish
    starship
    tree
    file
    jq
    wget
    procps
    fastfetch
    bitwarden-cli
    android-tools
    pnpm

    # ── 版本控制 ──
    git
    gnumake
    tmux

    # ── 自定义脚本 ──
    mdpdf
    autosub

    # ── 梯子 ──
    v2rayn
    sing-box

    # ── Python ──
    python3
    uv
    ruff
    pyright

    # ── C/C++ ──
    gcc
    clang
    clang-tools
    cmake
    ninja
    gdb
    lldb

    # ── Rust ──
    rustc
    cargo
    rust-analyzer
    rustfmt
    clippy

    # ── 文件管理 ──
    thunar
    thunar-volman
    gvfs
    lxqt.lxqt-policykit

    # ── 蓝牙 ──
    bluez
    bluez-tools
    kdePackages.bluedevil

    # ── 桌面应用 ──
    kdePackages.polkit-kde-agent-1
    google-chrome
    home-manager
    nodejs_22
    vscode
    wechat
    wpsoffice-cn
    helix

    # ── 多媒体 ──
    kdePackages.gwenview
    kdePackages.elisa
    go-musicfox
    flameshot

    # ── 阅读/文档 ──
    marktext
    sioyek
    pandoc
    texliveFull
    calibre
    anki

    # ── 视频播放 ──
    mpv
    haruna

    # ── 字幕生成 ──
    whisper-cpp
    ffmpeg

    # ── AI ──
    codex
    opencode
    opencode-desktop
    mcp-nixos
    github-mcp-server

    # ── 工具 ──
    ttyd
    lunar-client
    wl-clipboard
    cliphist
    qalculate-qt
    geary
    goldendict-ng
    kdePackages.ark
    p7zip
    unzip
    zip
    unrar
  ];
}
