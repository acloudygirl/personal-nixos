# 安全模块聚合
# 将所有安全相关配置集中管理
{ ... }:

{
  imports = [
    ./aide.nix
    ./audit.nix
    ./hardening.nix
  ];
}
