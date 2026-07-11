{
  appLauncher = {
    autoPasteClipboard = false;
    clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
    clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
    clipboardWrapText = true;
    customLaunchPrefix = "";
    customLaunchPrefixEnabled = false;
    density = "default";
    enableClipPreview = true;
    enableClipboardChips = true;
    enableClipboardHistory = true;
    enableClipboardSmartIcons = true;
    enableSessionSearch = true;
    enableSettingsSearch = true;
    enableWindowsSearch = true;
    iconMode = "tabler";
    ignoreMouseInput = false;
    overviewLayer = false;
    pinnedApps = [];
    position = "center";
    screenshotAnnotationTool = "";
    showCategories = true;
    showIconBackground = false;
    sortByMostUsed = true;
    terminalCommand = "alacritty -e";
    viewMode = "list";
  };

  calendar = {
    cards = [
      {
        enabled = true;
        id = "calendar-header-card";
      }
      {
        enabled = true;
        id = "calendar-month-card";
      }
      {
        enabled = true;
        id = "weather-card";
      }
    ];
  };

  controlCenter = {
    cards = [
      {
        enabled = true;
        id = "profile-card";
      }
      {
        enabled = true;
        id = "shortcuts-card";
      }
      {
        enabled = true;
        id = "audio-card";
      }
      {
        enabled = false;
        id = "brightness-card";
      }
      {
        enabled = true;
        id = "weather-card";
      }
      {
        enabled = true;
        id = "media-sysmon-card";
      }
    ];
    diskPath = "/";
    position = "close_to_bar_button";
    shortcuts = {
      left = [
        { id = "Network"; }
        { id = "Bluetooth"; }
        { id = "WallpaperSelector"; }
        { id = "NoctaliaPerformance"; }
      ];
      right = [
        { id = "Notifications"; }
        { id = "PowerProfile"; }
        { id = "KeepAwake"; }
        { id = "NightLight"; }
      ];
    };
  };

  desktopWidgets = {
    enabled = true;
    gridSnap = false;
    gridSnapScale = false;
    monitorWidgets = [
      {
        name = "eDP-1";
        widgets = [
          {
            id = "Weather";
            roundedCorners = true;
            scale = 1.0174382844214496;
            showBackground = true;
            x = 1785;
            y = 1182;
          }
        ];
      }
    ];
    overviewEnabled = true;
  };

  sessionMenu = {
    countdownDuration = 10000;
    enableCountdown = true;
    largeButtonsLayout = "single-row";
    largeButtonsStyle = true;
    position = "center";
    powerOptions = [
      {
        action = "lock";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "1";
      }
      {
        action = "suspend";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "2";
      }
      {
        action = "hibernate";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "3";
      }
      {
        action = "reboot";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "4";
      }
      {
        action = "logout";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "5";
      }
      {
        action = "shutdown";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "6";
      }
      {
        action = "rebootToUefi";
        command = "";
        countdownEnabled = true;
        enabled = true;
        keybind = "7";
      }
      {
        action = "userspaceReboot";
        command = "";
        countdownEnabled = true;
        enabled = false;
        keybind = "";
      }
    ];
    showHeader = true;
    showKeybinds = true;
  };

  plugins = {
    autoUpdate = true;
    notifyUpdates = true;
  };

  templates = {
    activeTemplates = [];
    enableUserTheming = false;
  };
}
