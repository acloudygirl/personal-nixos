{ ... }:

{
  # 主要本地用户
  users.users.cloudygirl = {
    isNormalUser = true;
    extraGroups = [ "networkmanager" "wheel" ];
  };
}
