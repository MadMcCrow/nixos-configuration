# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "org/gnome/Console" = {
      font-scale = 1.0;
      last-window-size = mkTuple [ 652 481 ];
    };

    "org/gnome/GWeather4" = {
      temperature-unit = "centigrade";
    };

    "org/gnome/Weather" = {
      locations = "[<(uint32 2, <('Paris', 'LFPB', true, [(0.85462956287765413, 0.042760566673861078)], [(0.8528842336256599, 0.040724343395436846)])>)>]";
    };

    "org/gnome/baobab/ui" = {
      is-maximized = false;
      window-size = mkTuple [ 960 600 ];
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
      window-state = mkTuple [ 980 640 ];
    };

    "org/gnome/deja-dup" = {
      prompt-check = "disabled";
      window-height = 500;
      window-width = 700;
    };

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "Accessories" "Code" "Graphics" "Games" ];
    };

    "org/gnome/desktop/app-folders/folders/Accessories" = {
      apps = [ "org.gnome.Maps.desktop" "org.gnome.Todo.desktop" "org.gnome.Weather.desktop" "org.gnome.Contacts.desktop" "org.gnome.Calendar.desktop" "org.gnome.Calculator.desktop" "org.gnome.Notes.desktop" "org.gnome.clocks.desktop" "com.github.maoschanz.drawing.desktop" "org.gnome.Geary.desktop" "pidgin.desktop" "org.gnome.Software.desktop" "org.gnome.TextEditor.desktop" "ca.andyholmes.Valent.desktop" "org.gnome.Keysign.desktop" ];
      categories = [ "Gnome" "Accessories" ];
      name = "Accessories";
    };

    "org/gnome/desktop/app-folders/folders/Code" = {
      apps = [ "org.gnome.gitg.desktop" "org.gnome.Sysprof.desktop" "nemiver.desktop" "codium.desktop" ];
      categories = [ "Code" "Programming" "Debug" ];
      name = "Programming";
    };

    "org/gnome/desktop/app-folders/folders/Games" = {
      apps = [ "steam.desktop" "net.openra.OpenRA-cnc.desktop" "net.openra.OpenRA.desktop" "net.openra.OpenRA-d2k.desktop" "info.beyondallreason.bar.desktop" "EVERSPACE.desktop" "valve-vrmonitor.desktop" "Warhammer 40,000 Dawn of War - Soulstorm.desktop" "valve-URI-vrmonitor.desktop" "valve-URI-steamvr.desktop" "How to Survive 2.desktop" "SteamVR.desktop" "io.github.sharkwouter.Minigalaxy.desktop" "Proton 4.2.desktop" "minecraft-launcher.desktop" ];
      categories = [ "Games" ];
      name = "Games";
    };

    "org/gnome/desktop/app-folders/folders/Graphics" = {
      apps = [ "org.inkscape.Inkscape.desktop" "gimp.desktop" "blender.desktop" ];
      categories = [ "Graphics" "Video" "Image" "3D" ];
      name = "Graphics";
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.eog.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" "nixos-manual.desktop" "org.gnome.Settings.desktop" "org.gnome.Extensions.desktop" "gnome-system-monitor.desktop" "org.gnome.Boxes.desktop" "psensor.desktop" "solaar.desktop" ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/keys-l.webp";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/keys-d.webp";
      primary-color = "#aaaaaa";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/input-sources" = {
      show-all-sources = false;
      sources = [ (mkTuple [ "xkb" "us+intl" ]) ];
      xkb-options = [ "eurosign:e" ];
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
      application-children = [ "firefox" "discord" "steam" "org-gnome-nautilus" "org-gnome-console" "org-gnome-dejadup" ];
    };

    "org/gnome/desktop/notifications/application/codium" = {
      application-id = "codium.desktop";
    };

    "org/gnome/desktop/notifications/application/com-mojang-minecraft" = {
      application-id = "com.mojang.Minecraft.desktop";
    };

    "org/gnome/desktop/notifications/application/discord" = {
      application-id = "discord.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/org-audacityteam-audacity" = {
      application-id = "org.audacityteam.Audacity.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-console" = {
      application-id = "org.gnome.Console.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-dejadup" = {
      application-id = "org.gnome.DejaDup.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-fileroller" = {
      application-id = "org.gnome.FileRoller.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-software" = {
      application-id = "org.gnome.Software.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
      application-id = "org.gnome.tweaks.desktop";
    };

    "org/gnome/desktop/notifications/application/steam" = {
      application-id = "steam.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "flat";
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
      switch-input-source = [ "<Super>space" "XF86Keyboard" ];
      switch-input-source-backward = [ "<Shift><Super>space" "<Shift>XF86Keyboard" ];
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

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 250;
      show-path = false;
      sort-method = "name";
      sort-type = "ascending";
    };

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 480;
      window-width = 600;
    };

    "org/gnome/gnome-system-monitor" = {
      current-tab = "resources";
      network-total-in-bits = false;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      center-new-windows = true;
      dynamic-workspaces = true;
      edge-tiling = true;
      focus-change-on-pointer-rest = true;
      overlay-key = "Super_L";
      workspaces-only-on-primary = true;
    };

    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [];
      toggle-tiled-right = [];
    };

    "org/gnome/mutter/wayland/keybindings" = {
      restore-shortcuts = [ "<Super>Escape" ];
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "icon-view";
      migrated-gtk-settings = true;
      search-filter-time-type = "last_modified";
      search-view = "list-view";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 890 550 ];
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = false;
    };

    "org/gnome/shell" = {
      app-picker-layout = "[{'Accessories': <{'position': <0>}>, 'Games': <{'position': <1>}>, 'Graphics': <{'position': <2>}>, 'Code': <{'position': <3>}>, 'Utilities': <{'position': <4>}>}]";
      command-history = [ "lg" "r" ];
      disable-user-extensions = false;
      disabled-extensions = [ "dash-to-dock@micxgx.gmail.com" "material-shell@papyelgringo" ];
      enabled-extensions = [ "quick-settings-tweaks@qwreey" "blur-my-shell@aunetx" "caffeine@patapon.info" "just-perfection-desktop@just-perfection" "openweather-extension@jenslody.de" "pano@elhan.io" "rocketbar@chepkun.github.com" "runcat@kolesnikov.se" "space-bar@luchrioh" "valent@andyholmes.ca" "wireless-hid@chlumskyvaclav.gmail.com" "user-theme@gnome-shell-extensions.gcampax.github.com" "gtk4-ding@smedius.gitlab.com" "alttab-mod@leleat-on-github" ];
      favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" "org.gnome.Console.desktop" "discord.desktop" "codium.desktop" "steam.desktop" ];
      looking-glass-history = [ "experimental_hdr=on" "global.compositor.backend.get_monitor_manager().experimental_hdr = 'on'" "exit()" "kill" "Exit" "exit" "log" "log( test)" "log( test )" "restart" "end" "return" ];
      welcome-dialog-last-shown-version = "43.2";
    };

    "org/gnome/shell/extensions/altTab-mod" = {
      disable-hover-select = false;
      remove-delay = true;
    };

    "org/gnome/shell/extensions/appindicator" = {
      icon-size = 0;
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
      indicator-position-max = 1;
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
      accessibility-menu = false;
      activities-button = false;
      activities-button-icon-monochrome = true;
      activities-button-label = true;
      animation = 1;
      app-menu = false;
      app-menu-icon = true;
      background-menu = true;
      clock-menu = true;
      clock-menu-position = 0;
      clock-menu-position-offset = 0;
      controls-manager-spacing-size = 0;
      dash = false;
      dash-icon-size = 0;
      dash-separator = false;
      double-super-to-appgrid = true;
      events-button = true;
      gesture = true;
      hot-corner = false;
      keyboard-layout = false;
      notification-banner-position = 2;
      osd = true;
      panel = true;
      panel-arrow = true;
      panel-corner-size = 0;
      panel-in-overview = true;
      panel-notification-icon = true;
      power-icon = true;
      ripple-box = true;
      search = false;
      show-apps-button = false;
      startup-status = 0;
      theme = false;
      top-panel-position = 0;
      weather = false;
      window-demands-attention-focus = false;
      window-picker-icon = true;
      window-preview-caption = true;
      window-preview-close-button = true;
      workspace = true;
      workspace-background-corner-size = 0;
      workspace-popup = false;
      workspace-switcher-should-show = true;
      workspace-switcher-size = 0;
      workspace-wrap-around = true;
      workspaces-in-app-grid = true;
      world-clock = false;
    };

    "org/gnome/shell/extensions/openweather" = {
      city = "48.9906696,2.2794326>Eaubonne, Argenteuil, Val-d'Oise, Île-de-France, France métropolitaine, 95600, France>0";
    };

    "org/gnome/shell/extensions/pano" = {
      keep-search-entry = false;
      link-previews = true;
      play-audio-on-copy = false;
      send-notification-on-copy = false;
      sync-primary = false;
    };

    "org/gnome/shell/extensions/quick-settings-tweaks" = {
      add-unsafe-quick-toggle-enabled = false;
      datemenu-fix-weather-widget = true;
      datemenu-remove-media-control = true;
      datemenu-remove-notifications = false;
      disable-adjust-content-border-radius = false;
      last-unsafe-state = false;
      list-buttons = "[{\"name\":\"SystemItem\",\"label\":null,\"visible\":true},{\"name\":\"OutputStreamSlider\",\"label\":null,\"visible\":false},{\"name\":\"InputStreamSlider\",\"label\":null,\"visible\":false},{\"name\":\"St_BoxLayout\",\"label\":null,\"visible\":true},{\"name\":\"BrightnessItem\",\"label\":null,\"visible\":true},{\"name\":\"NMWiredToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMWirelessToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMModemToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMBluetoothToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMVpnToggle\",\"label\":null,\"visible\":true},{\"name\":\"BluetoothToggle\",\"label\":\"Bluetooth\",\"visible\":false},{\"name\":\"PowerProfilesToggle\",\"label\":\"Power Mode\",\"visible\":false},{\"name\":\"NightLightToggle\",\"label\":\"Night Light\",\"visible\":true},{\"name\":\"DarkModeToggle\",\"label\":\"Dark Style\",\"visible\":true},{\"name\":\"RfkillToggle\",\"label\":\"Airplane Mode\",\"visible\":false},{\"name\":\"RotationToggle\",\"label\":\"Auto Rotate\",\"visible\":false},{\"name\":\"CaffeineToggle\",\"label\":\"Caffeine\",\"visible\":true},{\"name\":\"DndQuickToggle\",\"label\":\"Do Not Disturb\",\"visible\":true},{\"name\":\"BackgroundAppsToggle\",\"label\":null,\"visible\":false},{\"name\":\"MediaSection\",\"label\":null,\"visible\":false},{\"name\":\"Notifications\",\"label\":null,\"visible\":true}]";
      media-control-compact-mode = true;
      media-control-enabled = true;
      notifications-enabled = true;
      notifications-hide-when-no-notifications = true;
      notifications-integrated = true;
      notifications-max-height = 289;
      notifications-use-native-controls = true;
      user-removed-buttons = [ "Notifications" ];
    };

    "org/gnome/shell/extensions/rocketbar" = {
      activities-show-apps-button = "right_button";
      appbutton-backlight-dominant-color = true;
      appbutton-backlight-intensity = 3;
      appbutton-enable-notification-badges = true;
      appbutton-enable-sound-control = true;
      appbutton-icon-padding = 4;
      appbutton-icon-size = 16;
      appbutton-icon-vertical-padding = 4;
      appbutton-middle-button-sound-mute = true;
      appbutton-roundness = 20;
      appbutton-scroll-change-sound-volume = true;
      appbutton-spacing = 3;
      hotcorner-enable-in-fullscreen = false;
      indicator-display-limit = 4;
      indicator-dominant-color-active = true;
      indicator-dominant-color-inactive = true;
      indicator-height-active = 6;
      indicator-height-inactive = 4;
      indicator-position = "top";
      indicator-roundness-inactive = 6;
      indicator-spacing-active = 4;
      indicator-spacing-inactive = 2;
      indicator-width-active = 8;
      indicator-width-inactive = 4;
      notification-counter-enabled = true;
      notification-counter-hide-empty = true;
      notification-service-count-attention-sources = true;
      notification-service-enable-unity-dbus = true;
      overview-kill-dash = true;
      panel-menu-require-click = true;
      taskbar-enabled = true;
      taskbar-isolate-workspaces = false;
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

    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ "<Super>1" ];
      switch-to-application-2 = [ "<Super>2" ];
      switch-to-application-3 = [ "<Super>3" ];
      switch-to-application-4 = [ "<Super>4" ];
      switch-to-application-5 = [ "<Super>5" ];
      switch-to-application-6 = [ "<Super>6" ];
      switch-to-application-7 = [ "<Super>7" ];
      switch-to-application-8 = [ "<Super>8" ];
      switch-to-application-9 = [ "<Super>9" ];
      toggle-application-view = [ "<Super>a" ];
      toggle-overview = [ "<Super>s" ];
    };

    "org/gnome/shell/overrides" = {
      edge-tiling = true;
    };

    "org/gnome/software" = {
      check-timestamp = mkInt64 1697017974;
      first-run = false;
      flatpak-purge-timestamp = mkInt64 1695203836;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      show-hidden = true;
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 164;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 1172 301 ];
      window-size = mkTuple [ 1096 822 ];
    };

  };
}
