# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }:
let
  colors = flakes.colors;

  neovim-terminal = pkgs.callPackage flakes.packages.neovim-terminal {
    cursor = {
      foreground = colors.cursor.primary;
      background = colors.surface;
      inactive = {
        foreground = colors.bright.black;
        background = colors.surface;
      };
    };
  };
  nvim-term-class = "com.pseudoc.neovim-terminal";

  rgb = color: "rgb(${color})";
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

  home.packages = [
    pkgs.chromium
    pkgs-unstable.mattermost-desktop
    neovim-terminal
  ];

  programs.hyprlock = {
    enable = true;
    settings = {
      auth = {
        # cannot get fprint and password work together
        "fingerprint:enabled" = false;
      };

      general = {
        disable_loading_bar = false;
        hide_cursor = true;
      };

      background = [{
        path = wallpaper;
        blur_passes = 2;
      }];

      input-field = with flakes.colors; [{
        size = "320, 40";
        position = "0, -160";
        dots_center = true;
        font_color = rgb bright.black;
        inner_color = rgb surface;
        outer_color = rgb highlight;
        check_color = rgb green;
        fail_color = rgb bright.red;
        rounding = 10;
      }];

      label = with flakes.colors; [
        {
          text = "$TIME";
          color = rgb bright.white;
          font_size = "120";
          position = "0, -160";
          halign = "center";
          valign = "top";
        }
        {
          text = "$USER@zipzap";
          color = rgba bright.white "b0";
          font_size = "30";
          font_family = "GohuFont uni11 Nerd Font Mono";
          position = "0, -80";
          halign = "center";
          valign = "center";
        }
      ];
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 150;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 900;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ wallpaper ];
      wallpaper = [ ",${wallpaper}" ];
    };
  };

  services.cliphist.enable = true;

  wayland.windowManager.hyprland = let
    void = "42";
    browser = "24";
    chat = "23";
  in {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"];

    settings = {
      "$mod" = "SUPER";

      exec-once = [
        "hyprctl dispatch workspace ${void}"
      ];

      monitor = "eDP-1,preferred,auto,1.5";
      source = [
        # This file is not managed by Nix
        "~/.config/hypr/external-monitors.conf"
      ];

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

      bind = let
        wofi = lib.getExe pkgs.wofi;
        cliphist = lib.getExe pkgs.cliphist;
        wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
        ghostty = lib.getExe flakes.ghostty.packages.${pkgs.system}.default;
        nvim-term = lib.getExe' neovim-terminal "nvim-term";
      in [
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

        "$mod SHIFT, C, exec, ${cliphist} list | ${wofi} --dmenu | ${cliphist} decode | ${wl-copy}"
      ]
      ++ (let
        bindws = key: ws: [
          "$mod, ${key}, workspace, ${ws}"
          "$mod SHIFT, ${key}, movetoworkspace, ${ws}"
        ];
        genPair = i: let s = toString (i + 1); in { name = s; value = s; };
        pairs = with builtins; listToAttrs (genList genPair 9) // {
          "0" = void;
          "B" = browser;
          "C" = chat;
        };
        binds = lib.mapAttrsToList bindws pairs;
      in builtins.concatLists binds);

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];

      workspace = let 
        chromium = lib.getExe pkgs.chromium;
        mattermost = lib.getExe pkgs-unstable.mattermost-desktop;
      in [
        "${void}, monitor:eDP-1, default:true, defaultName:void"
        "${browser}, on-created-empty:${chromium}, defaultName:browser"
        "${chat}, on-created-empty:${mattermost}, defaultName:chat"
      ];
    };
  };
}
