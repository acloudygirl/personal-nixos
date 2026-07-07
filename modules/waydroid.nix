{ pkgs, ... }:

{
  # Use Waydroid's nftables variant; the current kernel does not provide the
  # legacy iptables modules that the default Waydroid network script prefers.
  networking.nftables.enable = true;
  networking.firewall.enable = true;

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  environment.systemPackages = with pkgs; [
    waydroid-helper
  ];
}
