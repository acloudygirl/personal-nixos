{
  nixrs = "git -C /home/cloudygirl/nixos add -A && nh os switch";
  ncg = "nh clean all";
  rollback = "nh os rollback";
  nixinfo = "nh os info";
  gitupdate = "git add . && git commit -m 'update' && git push";
  codenix = "z /nixos && code .";
}
