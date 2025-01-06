{
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      "$mod" = "SUPER";

      general = {
        gaps_in = 5;
        gaps_out = 15;
        border_size = 2;
        "col.active_border" = "rgba(3e8fb0ee) rgba(eb6f92ee) 30deg";
        "col.inactive_border" = "rgba(393552aa)";
        layout = "dwindle";
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      cursor = {
        enable_hyprcursor = true;
        inactive_timeout = 5;
      };

      input = {
        kb_layout = "us";
        touchpad = {
          natural_scroll = true;
        };
      };

      decoration = {
        active_opacity = 1;
        fullscreen_opacity = 1;
        inactive_opacity = 0.85;
        rounding = 7;

        blur = {
          enabled = true;
          size = 4;
          passes = 2;
        };

        shadow = {
          enabled = true;
          offset = "3 3";
          range = 8;
          "col.shadow" = "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easein,0.1, 0, 0.5, 0"
          "easeinback,0.35, 0, 0.95, -0.3"

          "easeout,0.5, 1, 0.9, 1"
          "easeoutback,0.35, 1.35, 0.65, 1"

          "easeinout,0.45, 0, 0.55, 1"
        ];

        animation = [
          "fadeIn,1,3,easeout"
          "fadeLayersIn,1,3,easeoutback"
          "layersIn,1,3,easeoutback,slide"
          "windowsIn,1,3,easeoutback,slide"

          "fadeLayersOut,1,3,easeinback"
          "fadeOut,1,3,easein"
          "layersOut,1,3,easeinback,slide"
          "windowsOut,1,3,easeinback,slide"

          "border,1,3,easeout"
          "fadeDim,1,3,easeinout"
          "fadeShadow,1,3,easeinout"
          "fadeSwitch,1,3,easeinout"
          "windowsMove,1,3,easeoutback"
          "workspaces,1,2.6,easeoutback,slide"
        ];
      };

      bind = [
        "$mod, T, exec, kitty"
        "$mod, D, killactive,"
        "$mod, V, togglefloating,"
        "$mod, C, centerwindow,"
        "$mod, F, fullscreen,"
        "$mod, P, pseudo,"
        "$mod, S, togglesplit,"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "$mod, mouse_up, workspace, e-1"
        "$mod, mouse_down, workspace, e+1"
      ] ++ (
        builtins.concatLists (builtins.genList (i:
          [
            "$mod, ${toString i}, workspace, ${toString i}"
            "$mod SHIFT, ${toString i}, movetoworkspace, ${toString i}"
          ]
        ) 9)
      );

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
