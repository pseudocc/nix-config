# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }:
let
  colors = flakes.colors;
in {
  services.swaync = {
    enable = true;
    settings = {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-icon-size = 32;
      notification-body-image-height = 128;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 400;
      control-center-height = 650;
      notification-window-width = 350;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;

      widgets = [
        "title"
        "volume"
        "notifications"
        "mpris"
        "dnd"
      ];

      widget-config.title = {
        text = "Notifications";
        clear-all-button = true;
        button-text = "Clear";
      };

      widget-config.dnd.text = "Do not disturb";

      widget-config.volume = {
        label = "";
        expand-button-label = "";
        collapse-button-label = "";
        show-per-app = true;
        show-per-app-icon = true;
        show-per-app-label = false;
      };

      widget-config.mpris = {
        image-size = 85;
        image-radius = 5;
      };
    };

    style = ''
      ${builtins.readFile ./swaync.css}
    '';
  };
}
