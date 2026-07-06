{ lib, pkgs, ... }:

let
  inherit (lib) genAttrs;

  chrome = "google-chrome.desktop";
  code = "code.desktop";
  thunar = "thunar.desktop";
  gwenview = "org.kde.gwenview.desktop";
  ark = "org.kde.ark.desktop";
  haruna = "org.kde.haruna.desktop";
  elisa = "org.kde.elisa.desktop";
  marktext = "marktext.desktop";
  sioyek = "sioyek.desktop";
  writer = "writer.desktop";
  calc = "calc.desktop";
  impress = "impress.desktop";
  telegram = "org.telegram.desktop.desktop";

  codeTypes = [
    "application/javascript"
    "application/json"
    "application/schema+json"
    "application/toml"
    "application/x-nix"
    "application/x-shellscript"
    "application/x-yaml"
    "application/xml"
    "text/css"
    "text/javascript"
    "text/plain"
    "text/x-c"
    "text/x-c++"
    "text/x-c++hdr"
    "text/x-c++src"
    "text/x-chdr"
    "text/x-cmake"
    "text/x-csrc"
    "text/x-java"
    "text/x-log"
    "text/x-makefile"
    "text/x-nix"
    "text/x-python"
    "text/x-shellscript"
    "text/x-toml"
    "text/x-yaml"
    "text/xml"
    "text/yaml"
  ];

  imageTypes = [
    "application/x-krita"
    "image/avif"
    "image/bmp"
    "image/gif"
    "image/heif"
    "image/jpeg"
    "image/jxl"
    "image/openraster"
    "image/png"
    "image/svg+xml"
    "image/svg+xml-compressed"
    "image/tiff"
    "image/webp"
    "image/x-icns"
    "image/x-ico"
    "image/x-portable-bitmap"
    "image/x-portable-graymap"
    "image/x-portable-pixmap"
    "image/x-psd"
    "image/x-tga"
    "image/x-webp"
    "image/x-xbitmap"
    "image/x-xcf"
    "image/x-xpixmap"
  ];

  archiveTypes = [
    "application/arj"
    "application/gzip"
    "application/vnd.debian.binary-package"
    "application/vnd.ms-cab-compressed"
    "application/vnd.rar"
    "application/x-7z-compressed"
    "application/x-archive"
    "application/x-arj"
    "application/x-bzip"
    "application/x-bzip-compressed-tar"
    "application/x-bzip2"
    "application/x-bzip2-compressed-tar"
    "application/x-compress"
    "application/x-compressed-tar"
    "application/x-cpio"
    "application/x-deb"
    "application/x-java-archive"
    "application/x-lrzip"
    "application/x-lrzip-compressed-tar"
    "application/x-lz4"
    "application/x-lz4-compressed-tar"
    "application/x-lzip"
    "application/x-lzip-compressed-tar"
    "application/x-lzma"
    "application/x-lzma-compressed-tar"
    "application/x-lzop"
    "application/x-rpm"
    "application/x-tar"
    "application/x-xz"
    "application/x-xz-compressed-tar"
    "application/x-zstd-compressed-tar"
    "application/zip"
    "application/zstd"
  ];

  audioTypes = [
    "application/ogg"
    "application/x-ogm-audio"
    "audio/aac"
    "audio/flac"
    "audio/mp4"
    "audio/mpeg"
    "audio/ogg"
    "audio/vorbis"
    "audio/x-flac"
    "audio/x-flac+ogg"
    "audio/x-mp3"
    "audio/x-mpegurl"
    "audio/x-ms-wma"
    "audio/x-opus+ogg"
    "audio/x-scpls"
    "audio/x-vorbis"
    "audio/x-vorbis+ogg"
    "audio/x-wav"
  ];

  videoTypes = [
    "video/mp2t"
    "video/mp4"
    "video/mpeg"
    "video/ogg"
    "video/quicktime"
    "video/webm"
    "video/x-flv"
    "video/x-matroska"
    "video/x-ms-wmv"
    "video/x-msvideo"
  ];

  mimeDefaults = {
    # Web
    "x-scheme-handler/http" = chrome;
    "x-scheme-handler/https" = chrome;
    "text/html" = chrome;
    "x-scheme-handler/tg" = telegram;
    "x-scheme-handler/tonsite" = telegram;

    # Files and directories
    "inode/directory" = thunar;

    # Markdown
    "text/markdown" = marktext;
    "text/x-markdown" = marktext;

    # PDF
    "application/pdf" = sioyek;

    # Office documents
    "application/msword" = writer;
    "application/vnd.ms-word" = writer;
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = writer;
    "application/vnd.ms-word.document.macroEnabled.12" = writer;
    "application/rtf" = writer;
    "text/rtf" = writer;
    "application/vnd.oasis.opendocument.text" = writer;

    "application/vnd.ms-excel" = calc;
    "application/msexcel" = calc;
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = calc;
    "application/vnd.ms-excel.sheet.macroEnabled.12" = calc;
    "text/csv" = calc;
    "application/vnd.oasis.opendocument.spreadsheet" = calc;

    "application/vnd.ms-powerpoint" = impress;
    "application/mspowerpoint" = impress;
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = impress;
    "application/vnd.openxmlformats-officedocument.presentationml.slideshow" = impress;
    "application/vnd.oasis.opendocument.presentation" = impress;

    # E-books and comics
    "application/epub+zip" = "okularApplication_epub.desktop";
    "application/x-cb7" = "okularApplication_comicbook.desktop";
    "application/x-cbr" = "okularApplication_comicbook.desktop";
    "application/x-cbt" = "okularApplication_comicbook.desktop";
    "application/x-cbz" = "okularApplication_comicbook.desktop";
  }
  // genAttrs codeTypes (_: code)
  // genAttrs imageTypes (_: gwenview)
  // genAttrs archiveTypes (_: ark)
  // genAttrs audioTypes (_: elisa)
  // genAttrs videoTypes (_: haruna);

in

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.cloudygirl = { config, ... }: {
      home.stateVersion = "26.05";

      home.packages = with pkgs; [
        noctalia-shell
        xwayland-satellite
        kitty
      ];

      systemd.user.services.polkit-kde-agent = {
        Unit = {
          Description = "KDE PolicyKit Authentication Agent";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.kdePackages.polkit-kde-agent-1}/libexec/polkit-kde-authentication-agent-1";
          Restart = "on-failure";
        };
        Install.WantedBy = [ "graphical-session.target" ];
      };

      xdg.configFile."niri/config.kdl".source = ./config/niri/config.kdl;
      xdg.dataFile."applications/wps-office-wps.desktop".source = ./config/wps-desktop/wps-office-wps.desktop;
      xdg.dataFile."applications/wps-office-et.desktop".source = ./config/wps-desktop/wps-office-et.desktop;
      xdg.dataFile."applications/wps-office-wpp.desktop".source = ./config/wps-desktop/wps-office-wpp.desktop;
      xdg.configFile."Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
        <action>
          <icon>utilities-terminal</icon>
          <name>Open Terminal Here</name>
          <submenu></submenu>
          <unique-id>1783058739735464-1</unique-id>
          <command>${pkgs.kitty}/bin/kitty --working-directory %f</command>
          <description>Open kitty in this directory</description>
          <range></range>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
        </action>
        <action>
          <icon>system-file-manager</icon>
          <name>Open as Administrator</name>
          <submenu></submenu>
          <unique-id>1783067653000000-1</unique-id>
          <command>${pkgs.thunar}/bin/thunar admin://%f</command>
          <description>Open this directory with administrator permissions</description>
          <range></range>
          <patterns>*</patterns>
          <startup-notify/>
          <directories/>
        </action>
        </actions>
      '';

      xdg.mimeApps = {
        enable = true;
        associations.added = mimeDefaults // {
          "inode/directory" = thunar;
          "application/pdf" = [
            sioyek
            "okularApplication_pdf.desktop"
          ];
          "image/png" = [
            gwenview
            "okularApplication_kimgio.desktop"
            chrome
          ];
          "image/jpeg" = [
            gwenview
            "okularApplication_kimgio.desktop"
            chrome
          ];
          "text/markdown" = [
            marktext
            "okularApplication_md.desktop"
            code
          ];
          "text/plain" = [
            code
            "Helix.desktop"
          ];
        };
        defaultApplications = mimeDefaults;
      };

      # Some desktops consult desktop-specific MIME files before the generic one.
      # Keep those entries linked to Home Manager's generated mimeapps.list.
      xdg.configFile."kde-mimeapps.list".source =
        config.xdg.configFile."mimeapps.list".source;
      xdg.configFile."niri-mimeapps.list".source =
        config.xdg.configFile."mimeapps.list".source;
      xdg.dataFile."applications/kde-mimeapps.list".source =
        config.xdg.configFile."mimeapps.list".source;
      xdg.dataFile."applications/niri-mimeapps.list".source =
        config.xdg.configFile."mimeapps.list".source;
    };

    backupFileExtension = ".bak";
  };
}
