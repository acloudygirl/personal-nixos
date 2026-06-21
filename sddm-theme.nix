{ pkgs, ... }:

let
  loginBackground = ./assets/login-bg.jpg;

  animeSddmTheme = (pkgs.sddm-astronaut.override {
    embeddedTheme = "japanese_aesthetic";
    themeConfig = {
      Font = "electroharmonix";
      FontSize = "11";
      RoundCorners = "26";
      Background = "Backgrounds/login-bg.jpg";
      BackgroundPlaceholder = "";
      BackgroundSpeed = "";
      CropBackground = "true";
      DimBackground = "0.12";

      FormPosition = "left";
      HaveFormBackground = "true";
      PartialBlur = "true";
      BlurMax = "32";
      Blur = "2.4";

      FormBackgroundColor = "#17172d";
      BackgroundColor = "#11111f";
      DimBackgroundColor = "#050512";
      LoginFieldBackgroundColor = "#0d1024";
      PasswordFieldBackgroundColor = "#0d1024";

      HeaderTextColor = "#c7e6ff";
      DateTextColor = "#c7e6ff";
      TimeTextColor = "#c7e6ff";
      LoginFieldTextColor = "#dff6ff";
      PasswordFieldTextColor = "#dff6ff";
      PlaceholderTextColor = "#9db5d6";
      UserIconColor = "#9bdcff";
      PasswordIconColor = "#ffb7e8";
      LoginButtonTextColor = "#080816";
      LoginButtonBackgroundColor = "#9bdcff";
      WarningColor = "#ffb7e8";
      HighlightBorderColor = "#ffb7e8";
      DropdownBackgroundColor = "#17172d";
      DropdownSelectedBackgroundColor = "#9bdcff";
      DropdownTextColor = "#dff6ff";
      HighlightBackgroundColor = "#ffb7e8";
      HighlightTextColor = "#080816";
      HoverUserIconColor = "#ffffff";
      HoverPasswordIconColor = "#ffffff";
      SessionButtonTextColor = "#c7e6ff";
      SystemButtonsIconsColor = "#c7e6ff";
      HoverSessionButtonTextColor = "#ffffff";
      HoverSystemButtonsIconsColor = "#ffffff";

      HideSystemButtons = "false";
      HideLoginButton = "false";
      HideVirtualKeyboard = "true";
      ForceLastUser = "true";
      PasswordFocus = "true";
      TranslateLogin = "UNLOCK";
      TranslatePlaceholderPassword = "PASSWORD";
    };
  }).overrideAttrs (oldAttrs: {
    installPhase = oldAttrs.installPhase + ''
      chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds
      cp ${loginBackground} $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/login-bg.jpg
    '';
  });
in
{
  services.displayManager.sddm = {
    enable = true;
    extraPackages = with pkgs.kdePackages; [
      qtmultimedia
      qtsvg
      qtvirtualkeyboard
    ];
    theme = "sddm-astronaut-theme";
  };

  environment.systemPackages = [
    animeSddmTheme
  ];
}
