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
      # 限制 GRUB 菜单中的内核数量，防止 /boot 空间耗尽
      configurationLimit = 5;
    };
  };
}
