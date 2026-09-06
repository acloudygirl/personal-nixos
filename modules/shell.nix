{ ... }:

{
  imports = [ ./shell-aliases.nix ];

  environment.variables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
