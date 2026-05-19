{ config, lib, ... }:
let
  configJson = {
    panelFamily = "ii";

    policies = {
      ai = 1;
      weeb = 0;
    };

    ai.extraModels = [
      {
        api_format = "openai";
        name = "Claude Sonnet (OpenRouter)";
        model = "anthropic/claude-sonnet-4";
        endpoint = "https://openrouter.ai/api/v1/chat/completions";
        homepage = "https://openrouter.ai/anthropic/claude-sonnet-4";
        icon = "spark-symbolic";
        key_get_link = "https://openrouter.ai/settings/keys";
        key_id = "openrouter";
        requires_key = true;
        description = "Claude via OpenRouter. Configure the OpenRouter key in the Quickshell settings UI.";
      }
      {
        api_format = "anthropic";
        name = "Claude Sonnet (Anthropic)";
        model = "claude-sonnet-4-20250514";
        endpoint = "https://api.anthropic.com/v1/messages";
        homepage = "https://www.anthropic.com/claude/sonnet";
        icon = "spark-symbolic";
        key_get_link = "https://console.anthropic.com/settings/keys";
        key_id = "anthropic";
        requires_key = true;
        description = "Claude via the native Anthropic Messages API. Store the key through the Quickshell settings UI.";
        extraParams.max_tokens = 4096;
      }
    ];

    apps = {
      bluetooth = "kcmshell6 kcm_bluetooth";
      network = "kcmshell6 kcm_networkmanagement";
      networkEthernet = "kcmshell6 kcm_networkmanagement";
      taskManager = "plasma-systemmonitor --page-name Processes";
      terminal = "foot";
      volumeMixer = "pavucontrol-qt";
    };

    appearance = {
      transparency = {
        enable = true;
        automatic = true;
        backgroundTransparency = 0.11;
        contentTransparency = 0.57;
      };
      wallpaperTheming = {
        enableAppsAndShell = true;
        enableQtApps = true;
        enableTerminal = true;
      };
    };

    background = {
      widgets = {
        clock.enable = false;
        quote.enable = false;
        weather.enable = true;
      };
      hideWhenFullscreen = true;
    };

    bar = {
      autoHide = {
        enable = true;
        hoverRegionWidth = 2;
        pushWindows = false;
        showWhenPressingSuper.enable = true;
      };
      cornerStyle = 1;
      floatStyleShadow = true;
      showBackground = true;
      verbose = true;
      weather = {
        enable = true;
        enableGPS = true;
        useUSCS = true;
      };
      workspaces = {
        showAppIcons = true;
        alwaysShowNumbers = false;
        useNerdFont = false;
      };
      utilButtons = {
        showScreenSnip = true;
        showColorPicker = true;
        showMicToggle = true;
        showKeyboardToggle = false;
        showDarkModeToggle = true;
        showPerformanceProfileToggle = false;
        showScreenRecord = true;
      };
    };

    calendar.locale = "en-US";

    conflictKiller = {
      autoKillNotificationDaemons = true;
      autoKillTrays = false;
    };

    dock.enable = false;

    launcher.pinnedApps = [
      "google-chrome"
      "foot"
      "obsidian"
      "org.kde.dolphin"
      "codium"
      "sidra"
    ];

    light = {
      night = {
        automatic = true;
        from = "19:00";
        to = "06:30";
        colorTemperature = 5000;
      };
      antiFlashbang.enable = false;
    };

    lock = {
      useHyprlock = false;
      launchOnStartup = false;
      centerClock = true;
      showLockedText = true;
      security = {
        unlockKeyring = true;
        requirePasswordToPower = false;
      };
    };

    media.filterDuplicatePlayers = true;

    notifications.timeout = 7000;

    osd.timeout = 1000;

    overview = {
      enable = true;
      rows = 2;
      columns = 5;
      centerIcons = true;
    };

    regionSelector = {
      targetRegions = {
        windows = true;
        layers = false;
        content = true;
        showLabel = false;
      };
      annotation.useSatty = true;
    };

    search.prefix = {
      showDefaultActionsWithoutPrefix = true;
      action = "/";
      app = ">";
      clipboard = ";";
      emojis = ":";
      math = "=";
      shellCommand = "$";
      webSearch = "?";
    };

    sidebar = {
      keepRightSidebarLoaded = true;
      translator.enable = false;
      quickSliders = {
        enable = true;
        showMic = true;
        showVolume = true;
        showBrightness = true;
      };
      quickToggles = {
        style = "android";
        android = {
          columns = 5;
          toggles = [
            { size = 2; type = "network"; }
            { size = 2; type = "bluetooth"; }
            { size = 1; type = "idleInhibitor"; }
            { size = 1; type = "mic"; }
            { size = 2; type = "audio"; }
            { size = 2; type = "nightLight"; }
          ];
        };
      };
    };

    sounds = {
      battery = false;
      pomodoro = false;
      theme = "freedesktop";
    };

    time = {
      format = "hh:mm AP";
      shortDateFormat = "MM/dd";
      dateWithYearFormat = "MM/dd/yyyy";
      dateFormat = "ddd, MM/dd";
      secondPrecision = false;
    };

    updates.enableCheck = false;

    wallpaperSelector.useSystemFileDialog = false;

    workSafety = {
      enable = {
        wallpaper = false;
        clipboard = false;
      };
    };
  };
in
{
  xdg.configFile."illogical-impulse/config.json".text =
    builtins.toJSON configJson;
}
