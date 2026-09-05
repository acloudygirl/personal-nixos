# Linux Audit 审计框架
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.security.auditRules;
in
{
  options.security.auditRules = {
    enable = mkEnableOption "自定义审计规则";
    
    rules = mkOption {
      type = types.listOf types.str;
      default = [
        "-w /etc/passwd -p wa -k identity"
        "-w /etc/shadow -p wa -k identity"
        "-w /etc/group -p wa -k identity"
        "-w /etc/ssh/sshd_config -p wa -k sshd"
      ];
      description = "审计规则";
    };
  };

  config = mkIf cfg.enable {
    security.auditd.enable = true;
    security.audit.enable = true;

    environment.etc."audit/rules.d/nixos.rules".text = 
      concatStringsSep "\n" cfg.rules;
  };
}
