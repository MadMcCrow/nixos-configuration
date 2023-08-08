# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "apps/psensor" = {
      graph-alpha-channel-enabled = true;
      graph-background-alpha = 0.702222;
      graph-background-color = "#ffffffffffff";
      graph-foreground-color = "#000000000000";
      graph-monitoring-duration = 20;
      graph-smooth-curves-enabled = false;
      graph-update-interval = 1;
      interface-hide-on-startup = false;
      interface-window-divider-pos = 1933;
      interface-window-h = 1011;
      interface-window-restore-enabled = true;
      interface-window-w = 2560;
      interface-window-x = 0;
      interface-window-y = 0;
      notif-script = "";
      provider-atiadlsdk-enabled = true;
      provider-gtop2-enabled = true;
      provider-hddtemp-enabled = true;
      provider-libatasmart-enabled = true;
      provider-lmsensors-enabled = true;
      provider-nvctrl-enabled = false;
      provider-udisks2-enabled = true;
      sensor-update-interval = 1;
      slog-enabled = true;
      slog-interval = 12;
    };

    "com/github/finefindus/eyedropper" = {
      is-maximized = false;
      window-height = 350;
      window-width = 342;
    };

    "com/github/maoschanz/drawing" = {
      last-active-tool = "pencil";
      last-version = "1.0.1";
      maximized = false;
    };

    "com/github/maoschanz/drawing/tools-options" = {
      last-active-shape = "polygon";
      last-delete-replace = "alpha";
      last-font-name = "Sans";
      last-left-rgba = [ "0.8" "0.0" "0.0" "1.0" ];
      last-right-rgba = [ "1.0" "1.0" "0.0" "0.5" ];
      last-shape-filling = "empty";
      last-size = 5;
      last-text-background = "outline";
      use-antialiasing = true;
    };

    "org/gnome/Console" = {
      last-window-size = mkTuple [ 756 1048 ];
    };

    "org/gnome/GWeather4" = {
      temperature-unit = "centigrade";
    };

    "org/gnome/Weather" = {
      locations = "[<(uint32 2, <('Paris', 'LFPB', true, [(0.85462956287765413, 0.042760566673861078)], [(0.8528842336256599, 0.040724343395436846)])>)>]";
    };

    "org/gnome/calculator" = {
      accuracy = 9;
      angle-units = "degrees";
      base = 10;
      button-mode = "basic";
      number-format = "automatic";
      show-thousands = false;
      show-zeroes = false;
      source-currency = "";
      source-units = "degree";
      target-currency = "";
      target-units = "radian";
      word-size = 64;
    };

    "org/gnome/control-center" = {
      last-panel = "bluetooth";
      window-state = mkTuple [ 2544 1032 ];
    };

    "org/gnome/deja-dup" = {
      backend = "google";
      prompt-check = "disabled";
      window-height = 500;
      window-width = 700;
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "Accessories" "Code" "Graphics" "Games" ];
    };

    "org/gnome/desktop/app-folders/folders/Accessories" = {
      apps = [ "org.gnome.Maps.desktop" "org.gnome.Todo.desktop" "org.gnome.Weather.desktop" "org.gnome.Contacts.desktop" "org.gnome.Calendar.desktop" "org.gnome.Calculator.desktop" "org.gnome.Notes.desktop" "org.gnome.clocks.desktop" "com.github.maoschanz.drawing.desktop" "org.gnome.Geary.desktop" "pidgin.desktop" "org.gnome.Software.desktop" "org.gnome.TextEditor.desktop" "ca.andyholmes.Valent.desktop" ];
      categories = [ "Gnome" "Accessories" ];
      name = "Accessories";
    };

    "org/gnome/desktop/app-folders/folders/Graphics" = {
      apps = [ "org.inkscape.Inkscape.desktop" "gimp.desktop" "blender.desktop" ];
      categories = [ "Graphics" "Video" "Image" "3D" ];
      name = "Graphics";
    };

    "org/gnome/desktop/app-folders/folders/Code" = {
      apps = [ "org.gnome.gitg.desktop" "org.gnome.Sysprof.desktop" "nemiver.desktop" "code.desktop" "codium.desktop" ];
      categories = [ "Code" "Programming" "Debug" ];
      name = "Programming";
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.eog.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" "nixos-manual.desktop" "org.gnome.Settings.desktop" "org.gnome.Extensions.desktop" "gnome-system-monitor.desktop" "org.gnome.Boxes.desktop" "psensor.desktop" "solaar.desktop" ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };


    "org/gnome/desktop/app-folders/folders/Games" = {
      apps = [ "steam.desktop" "net.openra.OpenRA-cnc.desktop" "net.openra.OpenRA.desktop" "net.openra.OpenRA-d2k.desktop" "info.beyondallreason.bar.desktop" ];
      categories = [ "Games" ];
      name = "Games";
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/keys-l.webp";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/keys-d.webp";
      primary-color = "#aaaaaa";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/interface" = {
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      cursor-size = 24;
      cursor-theme = "Adwaita";
      enable-animations = true;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      font-name = "Noto Sans,  10";
      gtk-theme = "adw-gtk3";
      icon-theme = "Adwaita";
      text-scaling-factor = 1.0;
      toolbar-style = "text";
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "discord" "steam" "gnome-power-panel" "firefox" "code" "org-gnome-console" "org-gnome-shell-extensions-gsconnect" "gimp" "org-gnome-nautilus" "org-gnome-software" "org-gnome-baobab" "codium" "org-gnome-dejadup" "info-beyondallreason-bar" ];
      show-banners = true;
    };

    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };

    "org/gnome/desktop/notifications/application/codium" = {
      application-id = "codium.desktop";
    };

    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gimp" = {
      application-id = "gimp.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/info-beyondallreason-bar" = {
      application-id = "info.beyondallreason.bar.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-baobab" = {
      application-id = "org.gnome.baobab.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-dejadup" = {
      application-id = "org.gnome.DejaDup.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-settings" = {
      application-id = "org.gnome.Settings.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-shell-extensions-gsconnect" = {
      application-id = "org.gnome.Shell.Extensions.GSConnect.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-software" = {
      application-id = "org.gnome.Software.desktop";
    };

    "org/gnome/desktop/notifications/application/steam" = {
      application-id = "steam.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/screensaver" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/keys-l.webp";
      primary-color = "#aaaaaa";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/search-providers" = {
      sort-order = [ "org.gnome.Contacts.desktop" "org.gnome.Documents.desktop" "org.gnome.Nautilus.desktop" ];
    };


    "org/gnome/desktop/wm/keybindings" = {
      maximize = [];
      switch-applications = [ "<Super>Tab" ];
      switch-applications-backward = [ "<Shift><Super>Tab" ];
      switch-windows = [ "<Alt>Tab" ];
      switch-windows-backward = [ "<Shift><Alt>Tab" ];
      unmaximize = [];
    };

    "org/gnome/desktop/wm/preferences" = {
      auto-raise = true;
      button-layout = "appmenu:minimize,maximize,close";
      focus-new-windows = "strict";
      workspace-names = [];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/gnome-system-monitor" = {
      current-tab = "resources";
      maximized = false;
      network-total-in-bits = false;
      show-dependencies = false;
      show-whose-processes = "user";
      window-state = mkTuple [ 700 500 ];
    };

    "org/gnome/gnome-system-monitor/disktreenew" = {
      col-6-visible = true;
      col-6-width = 0;
      columns-order = [ 0 1 2 3 4 5 6 ];
      sort-col = 3;
      sort-order = 0;
    };

    "org/gnome/gnome-system-monitor/proctree" = {
      columns-order = [ 0 1 2 3 4 6 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 ];
      sort-col = 8;
      sort-order = 0;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      center-new-windows = true;
      dynamic-workspaces = true;
      edge-tiling = false;
      focus-change-on-pointer-rest = true;
      overlay-key = "Super_L";
      workspaces-only-on-primary = true;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [];
      toggle-tiled-right = [];
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
      search-view = "list-view";
    };

    "org/gnome/shell" = {
      app-picker-layout = "[{'Utilities': <{'position': <0>}>, 'Accessories': <{'position': <1>}>, 'Code': <{'position': <2>}>, 'Games': <{'position': <3>}>}]";
      disable-user-extensions = false;
      disabled-extensions = [];
      enabled-extensions = [ "quick-settings-tweaks@qwreey" "blur-my-shell@aunetx" "caffeine@patapon.info" "just-perfection-desktop@just-perfection" "openweather-extension@jenslody.de" "pano@elhan.io" "rocketbar@chepkun.github.com" "runcat@kolesnikov.se" "space-bar@luchrioh" "valent@andyholmes.ca" "wireless-hid@chlumskyvaclav.gmail.com" "user-theme@gnome-shell-extensions.gcampax.github.com" "gtk4-ding@smedius.gitlab.com" "alttab-mod@leleat-on-github" ];
      favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" "steam.desktop" "org.gnome.Console.desktop" "discord.desktop" "codium.desktop" ];
      welcome-dialog-last-shown-version = "43.2";
    };

    "org/gnome/shell/extensions/altTab-mod" = {
      disable-hover-select = false;
      remove-delay = true;
    };

    "org/gnome/shell/extensions/blur-my-shell" = {
      hacks-level = 0;
    };

    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = false;
      blur-on-overview = true;
      customize = false;
      enable-all = false;
      opacity = 238;
    };

    "org/gnome/shell/extensions/blur-my-shell/hidetopbar" = {
      compatibility = true;
    };

    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      override-background = true;
    };

    "org/gnome/shell/extensions/caffeine" = {
      indicator-position-max = 2;
      restore-state = true;
      toggle-state = true;
      user-enabled = true;
    };


    "org/gnome/shell/extensions/gtk4-ding" = {
      add-volumes-opposite = false;
      show-home = false;
      show-trash = false;
      show-volumes = false;
    };

    "org/gnome/shell/extensions/just-perfection" = {
      accessibility-menu = true;
      activities-button = false;
      activities-button-label = false;
      app-menu = true;
      app-menu-icon = true;
      background-menu = false;
      clock-menu = true;
      controls-manager-spacing-size = 0;
      dash = false;
      dash-icon-size = 0;
      dash-separator = false;
      double-super-to-appgrid = true;
      events-button = true;
      gesture = true;
      hot-corner = false;
      keyboard-layout = true;
      osd = true;
      panel = true;
      panel-arrow = true;
      panel-corner-size = 0;
      panel-in-overview = true;
      panel-notification-icon = true;
      power-icon = false;
      ripple-box = false;
      search = true;
      show-apps-button = false;
      startup-status = 1;
      theme = true;
      weather = true;
      window-demands-attention-focus = true;
      window-picker-icon = true;
      window-preview-caption = true;
      window-preview-close-button = true;
      workspace = false;
      workspace-background-corner-size = 0;
      workspace-popup = false;
      workspace-switcher-should-show = false;
      workspace-wrap-around = true;
      workspaces-in-app-grid = true;
      world-clock = true;
    };

    "org/gnome/shell/extensions/pano" = {
      keep-search-entry = false;
      link-previews = true;
      play-audio-on-copy = false;
      send-notification-on-copy = false;
      sync-primary = false;
    };

    "org/gnome/shell/extensions/quick-settings-tweaks" = {
      datemenu-remove-notifications = true;
      disable-adjust-content-border-radius = false;
      list-buttons = "[{\"name\":\"SystemItem\",\"label\":null,\"visible\":true},{\"name\":\"OutputStreamSlider\",\"label\":null,\"visible\":true},{\"name\":\"InputStreamSlider\",\"label\":null,\"visible\":false},{\"name\":\"St_BoxLayout\",\"label\":null,\"visible\":true},{\"name\":\"BrightnessItem\",\"label\":null,\"visible\":false},{\"name\":\"NMWiredToggle\",\"label\":\"Wired\",\"visible\":true},{\"name\":\"NMWirelessToggle\",\"label\":\"Wi-Fi\",\"visible\":true},{\"name\":\"NMModemToggle\",\"label\":null,\"visible\":false},{\"name\":\"NMBluetoothToggle\",\"label\":null,\"visible\":false},{\"name\":\"NMVpnToggle\",\"label\":null,\"visible\":false},{\"name\":\"BluetoothToggle\",\"label\":\"Bluetooth\",\"visible\":false},{\"name\":\"PowerProfilesToggle\",\"label\":\"Power Mode\",\"visible\":true},{\"name\":\"NightLightToggle\",\"label\":\"Night Light\",\"visible\":true},{\"name\":\"DarkModeToggle\",\"label\":\"Dark Style\",\"visible\":true},{\"name\":\"RfkillToggle\",\"label\":\"Airplane Mode\",\"visible\":false},{\"name\":\"RotationToggle\",\"label\":\"Auto Rotate\",\"visible\":false},{\"name\":\"DndQuickToggle\",\"label\":\"Do Not Disturb\",\"visible\":true},{\"name\":\"BackgroundAppsToggle\",\"label\":\"No Background Apps\",\"visible\":false},{\"name\":\"MediaSection\",\"label\":null,\"visible\":false},{\"name\":\"Notifications\",\"label\":null,\"visible\":false}]";
      notifications-use-native-controls = true;
    };

    "org/gnome/shell/extensions/rocketbar" = {
      activities-show-apps-button = "right_button";
      appbutton-backlight-dominant-color = true;
      appbutton-backlight-intensity = 3;
      appbutton-enable-sound-control = true;
      appbutton-icon-padding = 4;
      appbutton-icon-size = 16;
      appbutton-icon-vertical-padding = 4;
      appbutton-middle-button-sound-mute = true;
      appbutton-roundness = 20;
      appbutton-scroll-change-sound-volume = true;
      appbutton-spacing = 3;
      hotcorner-enable-in-fullscreen = false;
      indicator-display-limit = 3;
      indicator-dominant-color-active = true;
      indicator-dominant-color-inactive = true;
      indicator-position = "top";
      indicator-spacing-active = 4;
      indicator-width-active = 10;
      indicator-width-inactive = 4;
      notification-counter-enabled = true;
      notification-counter-hide-empty = true;
      notification-service-count-attention-sources = true;
      notification-service-enable-unity-dbus = true;
      overview-kill-dash = false;
      panel-menu-require-click = true;
      taskbar-enabled = true;
      taskbar-position = "left";
      taskbar-position-offset = 2;
      taskbar-preserve-position = true;
    };

    "org/gnome/shell/extensions/runcat" = {
      idle-threshold = 10;
    };

    "org/gnome/shell/extensions/space-bar/behavior" = {
      position = "left";
      smart-workspace-names = true;
    };

    "org/gnome/shell/extensions/tiling-assistant" = {
      active-window-hint-color = "rgb(53,132,228)";
      last-version-installed = 41;
      overridden-settings = "{'org.gnome.mutter.edge-tiling': <false>}";
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "";
    };

    "org/gnome/shell/overrides" = {
      edge-tiling = true;
    };

    "org/gnome/software" = {
      first-run = false;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };
  };
}
