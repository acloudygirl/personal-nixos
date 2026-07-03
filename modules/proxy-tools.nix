{ pkgs, ... }:

{
  # 允许 sing-box 创建网络接口并绑定特权端口，启用TUN
  # 不需要让整个应用以 root 身份运行
  security.wrappers.sing-box = {
    owner = "root";
    group = "root";
    capabilities = "cap_net_admin,cap_net_bind_service+ep";
    source = "${pkgs.sing-box}/bin/sing-box";
  };

  # v2rayN 需要在这个用户可写路径找到 sing-box 核心
  # 将它链接到上面 security.wrappers 生成的带能力包装器
  system.activationScripts.v2rayn-sing-box-core.text = ''
    ${pkgs.coreutils}/bin/install -d -o cloudygirl -g users -m 0755 /home/cloudygirl/.local/share/v2rayN/bin/sing_box
    ${pkgs.coreutils}/bin/ln -sfn /run/wrappers/bin/sing-box /home/cloudygirl/.local/share/v2rayN/bin/sing_box/sing-box
    ${pkgs.coreutils}/bin/chown -h cloudygirl:users /home/cloudygirl/.local/share/v2rayN/bin/sing_box/sing-box
  '';
}
