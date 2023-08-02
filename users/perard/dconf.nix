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

    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "YaST" "748c8450-5d6b-4339-b9f3-ede683cde9cd" "9981859f-c72f-4081-9b60-debc6d305f65" "7b071b91-2ee0-4f3e-8b38-6b3f48404147" "c44139e0-9372-436c-9f4d-35311e691a05" ];
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
      apps = [ "org.gnome.gitg.desktop" "org.gnome.Sysprof.desktop" "nemiver.desktop" "code.desktop" "codium.desktop" ];
      name = "Programming";
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      apps = [ "gnome-abrt.desktop" "gnome-system-log.desktop" "nm-connection-editor.desktop" "org.gnome.baobab.desktop" "org.gnome.Connections.desktop" "org.gnome.DejaDup.desktop" "org.gnome.Dictionary.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.eog.desktop" "org.gnome.Evince.desktop" "org.gnome.FileRoller.desktop" "org.gnome.fonts.desktop" "org.gnome.seahorse.Application.desktop" "org.gnome.tweaks.desktop" "org.gnome.Usage.desktop" "vinagre.desktop" "nixos-manual.desktop" "org.gnome.Settings.desktop" "org.gnome.Extensions.desktop" "gnome-system-monitor.desktop" "org.gnome.Boxes.desktop" "psensor.desktop" "solaar.desktop" ];
      categories = [ "X-GNOME-Utilities" ];
      name = "X-GNOME-Utilities.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/YaST" = {
      categories = [ "X-SuSE-YaST" ];
      name = "suse-yast.directory";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/c44139e0-9372-436c-9f4d-35311e691a05" = {
      apps = [ "steam.desktop" "net.openra.OpenRA-cnc.desktop" "net.openra.OpenRA.desktop" "wine-Programs-CNCOnline-C&C Online.desktop" "net.openra.OpenRA-d2k.desktop" ];
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

    "org/gnome/desktop/sound" = {
      event-sounds = true;
      theme-name = "__custom";
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

    "org/gnome/file-roller/dialogs/extract" = {
      recreate-folders = true;
      skip-newer = false;
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

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 1280 1048 ];
      maximized = false;
    };

    "org/gnome/shell" = {
      app-picker-layout = "[{'748c8450-5d6b-4339-b9f3-ede683cde9cd': <{'position': <0>}>, 'Utilities': <{'position': <1>}>}]";
      disable-user-extensions = false;
      disabled-extensions = [ "auto-move-windows@gnome-shell-extensions.gcampax.github.com" "native-window-placement@gnome-shell-extensions.gcampax.github.com" "unite@hardpixel.eu" "advanced-alt-tab@G-dH.github.com" "gTile@vibou" "gsconnect@andyholmes.github.io" "places-menu@gnome-shell-extensions.gcampax.github.com" "apps-menu@gnome-shell-extensions.gcampax.github.com" "dashbar@fthx" "forge@jmmaranan.com" "dash-to-panel@jderose9.github.com" "dash-to-dock@micxgx.gmail.com" "window-list@gnome-shell-extensions.gcampax.github.com" "arcmenu@arcmenu.com" "workspace-indicator@gnome-shell-extensions.gcampax.github.com" ];
      enabled-extensions = [ "appindicatorsupport@rgcjonas.gmail.com" "quick-settings-tweaks@qwreey" "gsconnect@andyholmes.github.io" "runcat@kolesnikov.se" "user-theme@gnome-shell-extensions.gcampax.github.com" "caffeine@patapon.info" "unite@hardpixel.eu" "gtk4-ding@smedius.gitlab.com" "just-perfection-desktop@just-perfection" "valent@andyholmes.ca" "wireless-hid@chlumskyvaclav.gmail.com" "dash2dock-lite@icedman.github.com" "pano@elhan.io" "alttab-mod@leleat-on-github" "space-bar@luchrioh" "blur-my-shell@aunetx" "tiling-assistant@leleat-on-github" "rocketbar@chepkun.github.com" "weatherornot@somepaulo.github.io" ];
      favorite-apps = [ "org.gnome.Nautilus.desktop" "firefox.desktop" "steam.desktop" "org.gnome.Console.desktop" "discord.desktop" "codium.desktop" ];
      welcome-dialog-last-shown-version = "43.2";
    };

    "org/gnome/shell/extensions/advanced-alt-tab-window-switcher" = {
      app-switcher-popup-hide-win-counter-for-single-window = true;
      app-switcher-popup-win-counter = true;
      hot-edge-mode = 0;
      hot-edge-monitor = 1;
      switcher-popup-hot-keys = false;
      switcher-popup-position = 2;
      switcher-popup-theme = 0;
      switcher-popup-tooltip-title = 1;
      win-switch-skip-minimized = true;
      win-switcher-popup-order = 3;
      ws-switch-popup = true;
    };

    "org/gnome/shell/extensions/altTab-mod" = {
      disable-hover-select = true;
      remove-delay = true;
    };

    "org/gnome/shell/extensions/arcmenu" = {
      activate-on-hover = true;
      dash-to-panel-standalone = true;
      enable-horizontal-flip = true;
      enable-standlone-runner-menu = true;
      enable-unity-homescreen = true;
      force-menu-location = "TopCentered";
      gnome-dash-show-applications = false;
      hide-overview-on-startup = true;
      menu-background-color = "rgb(30,37,41)";
      menu-border-color = "rgb(41,50,55)";
      menu-button-appearance = "None";
      menu-foreground-color = "rgb(189,230,251)";
      menu-item-active-bg-color = "rgba(189,230,251,0.15)";
      menu-item-active-fg-color = "rgb(189,230,251)";
      menu-item-hover-bg-color = "rgba(189,230,251,0.08)";
      menu-item-hover-fg-color = "rgb(189,230,251)";
      menu-layout = "GnomeOverview";
      menu-separator-color = "rgba(99,99,98,0.56)";
      multi-monitor = false;
      override-menu-theme = false;
      position-in-panel = "Left";
      prefs-visible-page = 0;
      raven-position = "Right";
      runner-position = "Centered";
      runner-search-display-style = "Grid";
      runner-show-frequent-apps = true;
      search-entry-border-radius = mkTuple [ true 25 ];
      show-activities-button = true;
      vert-separator = true;
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

    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = 1.0;
      customize = true;
      override-background = true;
      sigma = 0;
      unblur-in-overview = true;
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

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = false;
      background-opacity = 0.8;
      custom-theme-shrink = true;
      customize-alphas = true;
      dash-max-icon-size = 68;
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

    "org/gnome/shell/extensions/dash-to-panel" = {
      animate-appicon-hover = true;
      animate-appicon-hover-animation-extent = "{'RIPPLE': 4, 'PLANK': 4, 'SIMPLE': 1}";
      animate-appicon-hover-animation-travel = "{'SIMPLE': 0.10000000000000001, 'RIPPLE': 0.40000000000000002, 'PLANK': 0.0}";
      appicon-margin = 4;
      appicon-padding = 4;
      available-monitors = [ 0 ];
      dot-color-dominant = true;
      dot-color-override = false;
      dot-position = "LEFT";
      dot-style-focused = "METRO";
      dot-style-unfocused = "METRO";
      hide-overview-on-startup = true;
      hotkeys-overlay-combo = "TEMPORARILY";
      intellihide = true;
      intellihide-hide-from-windows = true;
      intellihide-show-in-fullscreen = false;
      intellihide-use-pressure = true;
      leftbox-padding = -1;
      leftbox-size = 0;
      overview-click-to-exit = true;
      panel-anchors = ''
        {"0":"MIDDLE"}\\n\n
      '';
      panel-lengths = ''
        {"0":100}\\n\n
      '';
      panel-positions = ''
        {"0":"LEFT"}\\n\n
      '';
      panel-sizes = ''
        {"0":64}\\n\n
      '';
      primary-monitor = 0;
      secondarymenu-contains-showdetails = true;
      show-appmenu = false;
      show-apps-icon-file = "";
      status-icon-padding = -1;
      stockgs-keep-dash = false;
      stockgs-keep-top-panel = false;
      stockgs-panelbtn-click-only = false;
      trans-bg-color = "#ffa348";
      trans-gradient-bottom-opacity = 0.0;
      trans-gradient-top-color = "#000000";
      trans-gradient-top-opacity = 0.1;
      trans-panel-opacity = 0.0;
      trans-use-custom-bg = false;
      trans-use-custom-gradient = true;
      trans-use-custom-opacity = true;
      trans-use-dynamic-opacity = false;
      tray-padding = -1;
      tray-size = 10;
      window-preview-title-position = "TOP";
    };

    "org/gnome/shell/extensions/dash2dock-lite" = {
      animate-icons-unmute = true;
      animation-magnify = 0.29;
      animation-rise = 0.57;
      animation-spread = 0.4;
      autohide-dash = true;
      border-radius = 2.319588;
      calendar-icon = false;
      clock-icon = false;
      customize-topbar = false;
      debug-visual = false;
      icon-effect = 0;
      icon-effect-color = mkTuple [ 0.0 0.0 ];
      icon-size = 0.0;
      monitor-count = 1;
      mounted-icon = true;
      msg-to-ext = "";
      open-app-animation = true;
      panel-mode = true;
      peek-hidden-icons = true;
      pressure-sense = true;
      scroll-sensitivity = 0.25;
      shrink-icons = false;
      topbar-background-color = mkTuple [ 0.66 0.2398 ];
      trash-icon = true;
    };

    "org/gnome/shell/extensions/gsconnect" = {
      devices = [];
      id = "9f8fefd0-ca95-4e1a-a94e-be850b8c13ea";
      name = "nixAF";
    };

    "org/gnome/shell/extensions/gsconnect/device/fbec9f46a920bf9a" = {
      incoming-capabilities = [ "kdeconnect.battery" "kdeconnect.battery.request" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report.request" "kdeconnect.contacts.request_all_uids_timestamps" "kdeconnect.contacts.request_vcards_by_uid" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.action" "kdeconnect.notification.reply" "kdeconnect.notification.request" "kdeconnect.photo.request" "kdeconnect.ping" "kdeconnect.runcommand" "kdeconnect.sftp.request" "kdeconnect.share.request" "kdeconnect.share.request.update" "kdeconnect.sms.request" "kdeconnect.sms.request_attachment" "kdeconnect.sms.request_conversation" "kdeconnect.sms.request_conversations" "kdeconnect.systemvolume" "kdeconnect.telephony.request" "kdeconnect.telephony.request_mute" ];
      last-connection = "lan://192.168.1.185:1716";
      name = "ONEPLUS A3003";
      outgoing-capabilities = [ "kdeconnect.battery" "kdeconnect.battery.request" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report" "kdeconnect.contacts.response_uids_timestamps" "kdeconnect.contacts.response_vcards" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.request" "kdeconnect.photo" "kdeconnect.ping" "kdeconnect.presenter" "kdeconnect.runcommand.request" "kdeconnect.sftp" "kdeconnect.share.request" "kdeconnect.sms.attachment_file" "kdeconnect.sms.messages" "kdeconnect.systemvolume.request" "kdeconnect.telephony" ];
      supported-plugins = [ "battery" "clipboard" "connectivity_report" "contacts" "findmyphone" "mousepad" "mpris" "notification" "photo" "ping" "presenter" "runcommand" "sftp" "share" "sms" "systemvolume" "telephony" ];
      type = "phone";
    };

    "org/gnome/shell/extensions/gsconnect/preferences" = {
      window-maximized = false;
      window-size = mkTuple [ 640 440 ];
    };

    "org/gnome/shell/extensions/gtile" = {
      auto-close = false;
      theme = "Default";
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
      search = false;
      show-apps-button = false;
      startup-status = 1;
      theme = true;
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
      list-buttons = "[{\"name\":\"SystemItem\",\"label\":null,\"visible\":true},{\"name\":\"OutputStreamSlider\",\"label\":null,\"visible\":true},{\"name\":\"InputStreamSlider\",\"label\":null,\"visible\":false},{\"name\":\"St_BoxLayout\",\"label\":null,\"visible\":true},{\"name\":\"BrightnessItem\",\"label\":null,\"visible\":false},{\"name\":\"NMWiredToggle\",\"label\":\"Wired\",\"visible\":true},{\"name\":\"NMWirelessToggle\",\"label\":\"Wi-Fi\",\"visible\":true},{\"name\":\"NMModemToggle\",\"label\":null,\"visible\":false},{\"name\":\"NMBluetoothToggle\",\"label\":null,\"visible\":false},{\"name\":\"NMVpnToggle\",\"label\":null,\"visible\":false},{\"name\":\"BluetoothToggle\",\"label\":\"Bluetooth\",\"visible\":true},{\"name\":\"PowerProfilesToggle\",\"label\":\"Power Mode\",\"visible\":true},{\"name\":\"NightLightToggle\",\"label\":\"Night Light\",\"visible\":true},{\"name\":\"DarkModeToggle\",\"label\":\"Dark Style\",\"visible\":true},{\"name\":\"RfkillToggle\",\"label\":\"Airplane Mode\",\"visible\":false},{\"name\":\"RotationToggle\",\"label\":\"Auto Rotate\",\"visible\":false},{\"name\":\"CaffeineToggle\",\"label\":\"Caffeine\",\"visible\":true},{\"name\":\"DndQuickToggle\",\"label\":\"Do Not Disturb\",\"visible\":true},{\"name\":\"BackgroundAppsToggle\",\"label\":\"No Background Apps\",\"visible\":false},{\"name\":\"MediaSection\",\"label\":null,\"visible\":false},{\"name\":\"Notifications\",\"label\":null,\"visible\":false}]";
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

    "org/gnome/shell/extensions/unite" = {
      autofocus-windows = false;
      extend-left-box = false;
      greyscale-tray-icons = true;
      hide-activities-button = "always";
      hide-app-menu-icon = false;
      hide-dropdown-arrows = true;
      hide-window-titlebars = "never";
      reduce-panel-spacing = false;
      show-legacy-tray = true;
      show-window-buttons = "never";
      show-window-title = "maximized";
      window-buttons-placement = "left";
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

    "org/gtk/gtk4/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.66 0.2398 ]) (mkTuple [ 0.0 0.0 ]) (mkTuple [ 1.0 0.964706 ]) (mkTuple [ 0.705882 0.654902 ]) (mkTuple [ 6.6667e-2 0.780392 ]) (mkTuple [ 0.968627 0.635294 ]) (mkTuple [ 0.92549 0.368627 ]) ];
      selected-color = mkTuple [ true 1.0 ];
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = true;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 140;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      view-type = "list";
      window-size = mkTuple [ 825 374 ];
    };

    "org/gtk/settings/color-chooser" = {
      custom-colors = [ (mkTuple [ 0.447059 0.623529 ]) (mkTuple [ 0.988235 0.913725 ]) (mkTuple [ 0.909987 0.909987 ]) (mkTuple [ 0.8 0.0 ]) (mkTuple [ 1.0 1.0 ]) ];
      selected-color = mkTuple [ true 0.447059 ];
    };

    "org/gtk/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 348;
      sort-column = "name";
      sort-directories-first = false;
      sort-order = "ascending";
      type-format = "category";
      window-position = mkTuple [ 35 32 ];
      window-size = mkTuple [ 1195 902 ];
    };

  };
}
