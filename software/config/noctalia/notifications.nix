{
  notifications = {
    backgroundOpacity = 1;
    clearDismissed = true;
    criticalUrgencyDuration = 15;
    density = "default";
    enableBatteryToast = true;
    enableKeyboardLayoutToast = true;
    enableMarkdown = false;
    enableMediaToast = false;
    enabled = true;
    location = "top_right";
    lowUrgencyDuration = 3;
    monitors = [];
    normalUrgencyDuration = 8;
    overlayLayer = true;
    respectExpireTimeout = false;
    saveToHistory = {
      critical = true;
      low = true;
      normal = true;
    };
    sounds = {
      criticalSoundFile = "";
      enabled = false;
      excludedApps = "discord,firefox,chrome,chromium,edge";
      lowSoundFile = "";
      normalSoundFile = "";
      separateSounds = false;
      volume = 0.5;
    };
  };

  osd = {
    autoHideMs = 2000;
    backgroundOpacity = 1;
    enabled = true;
    enabledTypes = [0 1 2];
    location = "top_right";
    monitors = [];
    overlayLayer = true;
  };
}
