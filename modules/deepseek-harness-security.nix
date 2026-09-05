{ config, pkgs, ... }:

{
  # 启用firejail沙箱
  programs.firejail.enable = true;
  
  # 创建专用用户运行deepseek harness
  users.users.dsh-runner = {
    isNormalUser = true;
    description = "DeepSeek Harness restricted user";
    extraGroups = [ ];  # 不加入任何特权组
    home = "/home/dsh-runner";
    createHome = true;
    shell = pkgs.bash;
  };
  
  # 限制docker组（如果不需要deepseek访问docker）
  # users.users.cloudygirl.extraGroups = lib.mkForce [ "networkmanager" "wheel" ];
  
  # 安全内核参数
  security.lockKernelModules = false;  # 保持false以允许必要模块
  security.hideProcessInformation = false;  # 保持false以允许调试
  
  # 限制用户权限
  security.pam.loginLimits = [
    # 限制dsh-runner用户的进程数
    { domain = "dsh-runner"; type = "hard"; item = "nproc"; value = "512"; }
    # 限制打开文件数
    { domain = "dsh-runner"; type = "hard"; item = "nofile"; value = "4096"; }
  ];
  
  # 防火墙规则（如果deepseek harness需要网络访问）
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ ];  # 根据需要添加端口
    # 如果deepseek harness需要访问特定端口，可以在这里添加
  };
}
