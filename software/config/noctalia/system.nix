{
  systemMonitor = {
    batteryCriticalThreshold = 5;
    batteryWarningThreshold = 20;
    cpuCriticalThreshold = 90;
    cpuWarningThreshold = 80;
    criticalColor = "";
    diskAvailCriticalThreshold = 10;
    diskAvailWarningThreshold = 20;
    diskCriticalThreshold = 90;
    diskWarningThreshold = 80;
    enableDgpuMonitoring = false;
    externalMonitor = "resources || missioncenter || jdsystemmonitor || corestats || system-monitoring-center || gnome-system-monitor || plasma-systemmonitor || mate-system-monitor || ukui-system-monitor || deepin-system-monitor || pantheon-system-monitor";
    gpuCriticalThreshold = 90;
    gpuWarningThreshold = 80;
    memCriticalThreshold = 90;
    memWarningThreshold = 80;
    swapCriticalThreshold = 90;
    swapWarningThreshold = 80;
    tempCriticalThreshold = 90;
    tempWarningThreshold = 80;
    useCustomColors = false;
    warningColor = "";
  };

  brightness = {
    backlightDeviceMappings = [];
    brightnessStep = 5;
    enableDdcSupport = false;
    enforceMinimum = true;
  };

  idle = {
    customCommands = "[]";
    enabled = false;
    fadeDuration = 5;
    lockCommand = "";
    lockTimeout = 660;
    resumeLockCommand = "";
    resumeScreenOffCommand = "";
    resumeSuspendCommand = "";
    screenOffCommand = "";
    screenOffTimeout = 600;
    suspendCommand = "";
    suspendTimeout = 1800;
  };

  noctaliaPerformance = {
    disableDesktopWidgets = false;
    disableWallpaper = false;
  };
}
