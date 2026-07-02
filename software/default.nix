{ pkgs, ... }:

let
  chrome = "google-chrome.desktop";
  code = "code.desktop";
  marktext = "marktext.desktop";
  sioyek = "sioyek.desktop";
  writer = "writer.desktop";
  calc = "calc.desktop";
  impress = "impress.desktop";
  telegram = "org.telegram.desktop.desktop";

  mimeDefaults = {
    # Web
    "x-scheme-handler/http" = chrome;
    "x-scheme-handler/https" = chrome;
    "text/html" = chrome;
    "x-scheme-handler/tg" = telegram;
    "x-scheme-handler/tonsite" = telegram;

    # Code and plain text. Nix files are currently detected as text/plain.
    "text/plain" = code;
    "application/x-nix" = code;
    "text/x-nix" = code;

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
  };

in

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.cloudygirl = _: {
      home.stateVersion = "26.05";

      home.packages = with pkgs; [
        noctalia-shell
        xwayland-satellite
        kitty
      ];

      xdg.configFile."niri/config.kdl".source = ./config/niri/config.kdl;

      xdg.mimeApps = {
        enable = true;
        associations.added = mimeDefaults // {
          "application/pdf" = [
            sioyek
            "okularApplication_pdf.desktop"
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
    };

    backupFileExtension = ".bak";
  };
}
