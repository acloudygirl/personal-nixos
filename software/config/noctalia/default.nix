{ lib, ... }:

let
  inherit (lib) foldl mergeAttrs;

  modules = [
    ./bar.nix
    ./dock.nix
    ./general.nix
    ./notifications.nix
    ./wallpaper.nix
    ./appearance.nix
    ./system.nix
    ./apps.nix
    ./misc.nix
  ];

  merged = foldl mergeAttrs {} (map (m: import m) modules);
in

merged // {
  settingsVersion = 59;
}
