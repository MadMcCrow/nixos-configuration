# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
   
    "org/gnome/GWeather4" = {
      temperature-unit = "centigrade";
    };

    "org/gnome/TextEditor" = {
      last-save-directory = "file:///home/perard";
    };

    "org/gnome/Weather" = {
      locations = "[<(uint32 2, <('Paris', 'LFPB', true, [(0.85462956287765413, 0.042760566673861078)], [(0.8528842336256599, 0.040724343395436846)])>)>]";
    };

    "org/gnome/baobab/ui" = {
      is-maximized = false;
      window-size = mkTuple [ 1280 1048 ];
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

    "org/gnome/desktop/app-folders/folders/748c8450-5d6b-4339-b9f3-ede683cde9cd" = {
      apps = [ "org.gnome.Maps.desktop" "org.gnome.Todo.desktop" "org.gnome.Weather.desktop" "org.gnome.Contacts.desktop" "org.gnome.Calendar.desktop" "org.gnome.Calculator.desktop" "org.gnome.Notes.desktop" "org.gnome.clocks.desktop" "com.github.maoschanz.drawing.desktop" "org.gnome.Geary.desktop" "pidgin.desktop" "org.gnome.Software.desktop" "org.gnome.TextEditor.desktop" ];
      name = "Accessories";
    };

    "org/gnome/desktop/app-folders/folders/7b071b91-2ee0-4f3e-8b38-6b3f48404147" = {
      apps = [ "org.inkscape.Inkscape.desktop" "gimp.desktop" "blender.desktop" ];
      name = "Graphics";
    };

    "org/gnome/desktop/app-folders/folders/9981859f-c72f-4081-9b60-debc6d305f65" = {
      apps = [ "org.gnome.gitg.desktop" "org.gnome.Sysprof.desktop" "nemiver.desktop" "code.desktop" ];
      name = "Programming";
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.eog.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" "nixos-manual.desktop" "org.gnome.Settings.desktop" "org.gnome.Extensions.desktop" "gnome-system-monitor.desktop" "org.gnome.Boxes.desktop" ];
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
      gtk-theme = "Adwaita";
      icon-theme = "Adwaita";
      text-scaling-factor = 1.0;
      toolbar-style = "text";
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "discord" "steam" "gnome-power-panel" "firefox" "code" "org-gnome-console" "org-gnome-shell-extensions-gsconnect" "gimp" "org-gnome-nautilus" "org-gnome-software" "org-gnome-baobab" "codium" "org-gnome-dejadup" "info-beyondallreason-bar" ];
      show-banners = true;
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

    "org/gnome/desktop/wm/keybindings" = {
      maximize = [];
      unmaximize = [];
    };

    "org/gnome/desktop/wm/preferences" = {
      auto-raise = true;
      button-layout = "appmenu:minimize,maximize,close";
      focus-new-windows = "strict";
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
    };

    "org/gnome/file-roller/dialogs/extract" = {
      recreate-folders = true;
      skip-newer = false;
    };

    "org/gnome/gnome-system-monitor/disktreenew" = {
      col-6-visible = true;
      col-6-width = 0;
      columns-order = [ 0 1 2 3 4 5 6 ];
      sort-col = 3;
      sort-order = 0;
    };

    "org/gnome/mutter" = {
      attach-modal-dialogs = true;
      dynamic-workspaces = true;
      edge-tiling = false;
      focus-change-on-pointer-rest = true;
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
      disable-user-extensions = false;
      enabled-extensions = [ "dash-to-dock@micxgx.gmail.com" "blur-my-shell@aunetx" "appindicatorsupport@rgcjonas.gmail.com" "quick-settings-tweaks@qwreey" "gsconnect@andyholmes.github.io" "runcat@kolesnikov.se" "user-theme@gnome-shell-extensions.gcampax.github.com" "caffeine@patapon.info" "unite@hardpixel.eu" "tiling-assistant@leleat-on-github" ];
      favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" "steam.desktop" "org.gnome.Console.desktop" "discord.desktop" "codium.desktop" ];
      welcome-dialog-last-shown-version = "43.2";
    };

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = false;
      brightness = 1.0;
      customize = true;
      override-background = false;
      sigma = 0;
      unblur-in-overview = true;
    };

    "org/gnome/shell/extensions/caffeine" = {
      indicator-position-max = 1;
      restore-state = true;
      toggle-state = true;
      user-enabled = true;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = false;
      background-opacity = 0.8;
      custom-theme-shrink = true;
      customize-alphas = true;
      dash-max-icon-size = 48;
      dock-position = "LEFT";
      extend-height = true;
      height-fraction = 0.9;
      isolate-workspaces = true;
      max-alpha = 0.6;
      min-alpha = 0.15;
      preferred-monitor = -2;
      preferred-monitor-by-connector = "HDMI-1";
      running-indicator-dominant-color = true;
      running-indicator-style = "DOTS";
      show-apps-at-top = true;
      show-mounts-network = true;
      show-trash = false;
      transparency-mode = "DYNAMIC";
    };

    "org/gnome/shell/extensions/quick-settings-tweaks" = {
      datemenu-remove-notifications = true;
      disable-adjust-content-border-radius = false;
      list-buttons = "[{\"name\":\"SystemItem\",\"label\":null,\"visible\":true},{\"name\":\"OutputStreamSlider\",\"label\":null,\"visible\":false},{\"name\":\"InputStreamSlider\",\"label\":null,\"visible\":false},{\"name\":\"St_BoxLayout\",\"label\":null,\"visible\":true},{\"name\":\"BrightnessItem\",\"label\":null,\"visible\":true},{\"name\":\"NMWiredToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMWirelessToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMModemToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMBluetoothToggle\",\"label\":null,\"visible\":true},{\"name\":\"NMVpnToggle\",\"label\":null,\"visible\":true},{\"name\":\"BluetoothToggle\",\"label\":\"Bluetooth\",\"visible\":false},{\"name\":\"PowerProfilesToggle\",\"label\":\"Power Mode\",\"visible\":false},{\"name\":\"NightLightToggle\",\"label\":\"Night Light\",\"visible\":true},{\"name\":\"DarkModeToggle\",\"label\":\"Dark Style\",\"visible\":true},{\"name\":\"RfkillToggle\",\"label\":\"Airplane Mode\",\"visible\":false},{\"name\":\"RotationToggle\",\"label\":\"Auto Rotate\",\"visible\":false},{\"name\":\"CaffeineToggle\",\"label\":\"Caffeine\",\"visible\":true},{\"name\":\"DndQuickToggle\",\"label\":\"Do Not Disturb\",\"visible\":true},{\"name\":\"BackgroundAppsToggle\",\"label\":null,\"visible\":false},{\"name\":\"MediaSection\",\"label\":null,\"visible\":false},{\"name\":\"Notifications\",\"label\":null,\"visible\":false}]";
      notifications-use-native-controls = true;
    };

    "org/gnome/shell/extensions/runcat" = {
      idle-threshold = 10;
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
      edge-tiling = false;
    };

    "org/gnome/shell/weather" = {
      automatic-location = true;
      locations = "[<(uint32 2, <('Paris', 'LFPB', true, [(0.85462956287765413, 0.042760566673861078)], [(0.8528842336256599, 0.040724343395436846)])>)>]";
    };

    "org/gnome/shell/world-clocks" = {
      locations = "@av []";
    };

    "org/gnome/software" = {
      first-run = false;
    };

    "org/gnome/tweaks" = {
      show-extensions-notice = false;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-size-column = true;
      show-type-column = true;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
    };

  };
}
