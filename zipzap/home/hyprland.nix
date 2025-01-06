{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      cursor.inactive_timeout = 5;
      input = {
        kb_layout = "us";
        touchpad = {
          natural_scroll = true;
        };
      };

      "$mod" = "SUPER";
      environment = {
        XCURSOR_SIZE = "24";
      };

      bind = [
        "$mod, T, exec, kitty"
      ];
    };
  };
}
