{ ... }:

{
  # 引导加载器：EFI 模式下的 GRUB，并探测其它已安装系统
  boot.loader = {
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
    };
  };
}
