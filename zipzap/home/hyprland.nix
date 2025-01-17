# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }:
let
  colors = flakes.colors;
  wofi = lib.getExe pkgs.wofi;
  ghostty = lib.getExe flakes.ghostty.packages.${pkgs.system}.default;
  nvim-term = lib.getExe' flakes.packages.neovim-terminal "nvim-term";
  nvim-term-class = "com.pseudoc.neovim-terminal";

  rgba = color: alpha: "rgba(${color}${alpha})";
  wallpaper = flakes.lib.embedFile {
    path = ./assets/wallpaper.jpg;
    sha256 = "sha256:0lbg9fyjkcw13n4fxnd14fj3fmq7lz5ydbzvakx2igy07gm2c7q9";
  };
in {
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
      common = { default = [ "gtk" ]; };
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ wallpaper ];
      wallpaper = [ ",${wallpaper}" ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"];

    settings = {
      "$mod" = "SUPER";

      general = {
        gaps_in = 5;
        gaps_out = 15;
        border_size = 2;
        layout = "dwindle";
        "col.active_border" = toString [
          (rgba colors.yellow "ff")
          (rgba colors.red "ff")
          "30deg"
        ];
        "col.inactive_border" = rgba colors.bright.black "cc";
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      cursor = {
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
          color = rgba colors.surface "ee";
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

      windowrulev2 = [
        "bordercolor ${rgba colors.highlight "ff"} ${rgba colors.cyan "cc"} 30deg, class:${nvim-term-class}"
      ];

      bind = [
        "$mod, T, exec, ${ghostty}"
        "$mod SHIFT, T, exec, ${ghostty} --command='${nvim-term}' --confirm-close-surface=false --class=${nvim-term-class}"
        "$mod, R, exec, ${wofi}"

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
        builtins.concatLists (builtins.genList (i: let
            key = toString i;
            ws = toString (i + 1);
          in [
            "$mod, ${key}, workspace, ${ws}"
            "$mod SHIFT, ${key}, movetoworkspace, ${ws}"
          ]
        ) 10)
      );

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
