# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }:
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
  mod = "SUPER";
in {

  imports = [
    ./wofi.nix
    ./waybar.nix
    ./swaync.nix
    ./kanshi.nix
    ./yazi.nix
  ];

  services.hypriio = {
    enable = true;
    settings = {
      output = "eDP-1";
      restart-services = [ "hyprpaper.service" ];
    };
  };

  home.packages = [
    pkgs.discord
    pkgs.qq
    # pkgs.wechat
    pkgs.chromium
    pkgs.mattermost-desktop
    neovim-terminal
  ];

  xdg.systemDirs.data = [
    "${pkgs.mattermost-desktop}/share"
    "${pkgs.chromium}/share"
  ];

  programs.hyprlock = {
    enable = true;
    settings = {
      auth.fingerprint.enable = true;

      general = {
        disable_loading_bar = false;
        hide_cursor = true;
      };

      background = [{
        path = wallpaper;
        blur_passes = 2;
      }];
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
          timeout = 300;
          on-timeout = "brightnessctl -s set 10";
          on-resume = "brightnessctl -r";
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
        {
          timeout = 750;
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
    settings.wallpaper = [{
      monitor = "";
      path = wallpaper;
      fit_mode = "cover";
    }];
  };

  services.cliphist.enable = true;

  catppuccin.hyprland.enable = false;

  wayland.windowManager.hyprland = let
    void = "42";
    browser = "24";
    chat = "23";
    QQ = "25";
    Steam = "26";
    lua = lib.generators.mkLuaInline;
    luaDispatcher = dispatcher: lua "hl.dsp.${dispatcher}";
    bind = keys: dispatcher: {
      _args = [
        keys
        (luaDispatcher dispatcher)
      ];
    };
  in {
    enable = true;
    xwayland.enable = true;
    systemd.variables = ["--all"];
    configType = "lua";

    settings = {
      monitor = {
        output = "eDP-1";
        mode = "highres";
        position = "auto";
        scale = "auto";
      };

      on = {
        _args = [
          "hyprland.start"
          (lua "function()\n  hl.dispatch(hl.dsp.focus({ workspace = \"${void}\" }))\nend")
        ];
      };

      config = {
        general = {
          gaps_in = 5;
          gaps_out = 15;
          border_size = 2;
          layout = "dwindle";
          col = {
            active_border = {
              colors = [
                (rgba colors.yellow "ff")
                (rgba colors.red "ff")
              ];
              angle = 30;
            };
            inactive_border = rgba colors.bright.black "cc";
          };
        };

        dwindle = {
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
            offset = [3 3];
            range = 8;
            color = rgba colors.surface "ee";
          };
        };

        animations.enabled = true;
      };

      curve = [
        {
          _args = [
            "easein"
            { type = "bezier"; points = [[0.1 0] [0.5 0]]; }
          ];
        }
        {
          _args = [
            "easeinback"
            { type = "bezier"; points = [[0.35 0] [0.95 (-0.3)]]; }
          ];
        }
        {
          _args = [
            "easeout"
            { type = "bezier"; points = [[0.5 1] [0.9 1]]; }
          ];
        }
        {
          _args = [
            "easeoutback"
            { type = "bezier"; points = [[0.35 1.35] [0.65 1]]; }
          ];
        }
        {
          _args = [
            "easeinout"
            { type = "bezier"; points = [[0.45 0] [0.55 1]]; }
          ];
        }
      ];

      animation = [
        { leaf = "fadeIn"; enabled = true; speed = 3; bezier = "easeout"; }
        { leaf = "fadeLayersIn"; enabled = true; speed = 3; bezier = "easeoutback"; }
        { leaf = "layersIn"; enabled = true; speed = 3; bezier = "easeoutback"; style = "slide"; }
        { leaf = "windowsIn"; enabled = true; speed = 3; bezier = "easeoutback"; style = "slide"; }
        { leaf = "fadeLayersOut"; enabled = true; speed = 3; bezier = "easeinback"; }
        { leaf = "fadeOut"; enabled = true; speed = 3; bezier = "easein"; }
        { leaf = "layersOut"; enabled = true; speed = 3; bezier = "easeinback"; style = "slide"; }
        { leaf = "windowsOut"; enabled = true; speed = 3; bezier = "easeinback"; style = "slide"; }
        { leaf = "border"; enabled = true; speed = 3; bezier = "easeout"; }
        { leaf = "fadeDim"; enabled = true; speed = 3; bezier = "easeinout"; }
        { leaf = "fadeShadow"; enabled = true; speed = 3; bezier = "easeinout"; }
        { leaf = "fadeSwitch"; enabled = true; speed = 3; bezier = "easeinout"; }
        { leaf = "windowsMove"; enabled = true; speed = 3; bezier = "easeoutback"; }
        { leaf = "workspaces"; enabled = true; speed = 2.6; bezier = "easeoutback"; style = "slide"; }
      ];

      window_rule = [
        {
          match.class = nvim-term-class;
          border_color = {
            colors = [
              (rgba colors.highlight "ff")
              (rgba colors.cyan "cc")
            ];
            angle = 30;
          };
        }
        {
          match.class = "steam";
          workspace = Steam;
        }
        {
          match = {
            class = "steam";
            title = "Friends List";
          };
          float = true;
          size = ["monitor_w*0.25" "monitor_h*0.8"];
        }
        {
          match.class = "steam_app_[0-9]+";
          immediate = true;
        }
      ];

      bind = let
        system = pkgs.stdenv.hostPlatform.system;
        wofi = lib.getExe pkgs.wofi;
        cliphist = lib.getExe pkgs.cliphist;
        wl-copy = lib.getExe' pkgs.wl-clipboard "wl-copy";
        ghostty = lib.getExe flakes.ghostty.packages.${system}.default;
        nvim-term = lib.getExe' neovim-terminal "nvim-term";
        swaync-client = lib.getExe' pkgs.swaynotificationcenter "swaync-client";
        set-scale = keys: scale: let
          luaScale =
            if builtins.isString scale
            then ''"${scale}"''
            else toString scale;
        in {
          _args = [
            keys
            (lua ''function()
              hl.monitor({ output = "eDP-1", mode = "highres", position = "auto", scale = ${luaScale} })
            end'')
          ];
        };
      in [
        (set-scale "${mod} + F1" 1)
        (set-scale "${mod} + SHIFT + F1" "auto")
        (bind "${mod} + T" "exec_cmd(${builtins.toJSON ghostty})")
        (bind "${mod} + SHIFT + T" "exec_cmd(${builtins.toJSON "${ghostty} --command='${nvim-term}' --confirm-close-surface=false --class=${nvim-term-class}"})")
        (bind "${mod} + R" "exec_cmd(${builtins.toJSON wofi})")

        (bind "${mod} + D" "window.close()")
        (bind "${mod} + V" "window.float()")
        (bind "${mod} + C" "window.center()")
        (bind "${mod} + F" "window.fullscreen()")
        (bind "${mod} + P" "window.pseudo()")
        (bind "${mod} + S" ''layout("togglesplit")'')

        (bind "${mod} + left" ''focus({ direction = "left" })'')
        (bind "${mod} + right" ''focus({ direction = "right" })'')
        (bind "${mod} + up" ''focus({ direction = "up" })'')
        (bind "${mod} + down" ''focus({ direction = "down" })'')

        (bind "${mod} + mouse_up" ''focus({ workspace = "e-1" })'')
        (bind "${mod} + mouse_down" ''focus({ workspace = "e+1" })'')

        (bind "${mod} + SHIFT + P" "exec_cmd(${builtins.toJSON "${cliphist} list | ${wofi} --dmenu | ${cliphist} decode | ${wl-copy}"})")
        (bind "${mod} + N" "exec_cmd(${builtins.toJSON "${swaync-client} -t"})")

        (bind "${mod} + SHIFT + left" ''workspace.move({ monitor = "l" })'')
        (bind "${mod} + SHIFT + right" ''workspace.move({ monitor = "r" })'')

        (bind "XF86MonBrightnessUp" ''exec_cmd("brightnessctl set +5%")'')
        (bind "XF86MonBrightnessDown" ''exec_cmd("brightnessctl set 5%-")'')
        (bind "XF86AudioRaiseVolume" ''exec_cmd("pamixer -i 5")'')
        (bind "XF86AudioLowerVolume" ''exec_cmd("pamixer -d 5")'')
        (bind "XF86AudioMute" ''exec_cmd("pamixer -t")'')
        (bind "XF86AudioMicMute" ''exec_cmd("pamixer --default-source -t")'')
      ]
      ++ (let
        bindws = key: ws: [
          (bind "${mod} + ${key}" "focus({ workspace = ${builtins.toJSON ws} })")
          (bind "${mod} + SHIFT + ${key}" "window.move({ workspace = ${builtins.toJSON ws}, follow = true })")
        ];
        genPair = i: let s = toString (i + 1); in { name = s; value = s; };
        pairs = with builtins; listToAttrs (genList genPair 9) // {
          "0" = void;
          "B" = browser;
          "C" = chat;
          "Q" = QQ;
          "G" = Steam;
        };
        binds = lib.mapAttrsToList bindws pairs;
      in builtins.concatLists binds)
      ++ [
        {
          _args = [
            "${mod} + mouse:272"
            (luaDispatcher "window.drag()")
            { mouse = true; }
          ];
        }
        {
          _args = [
            "${mod} + mouse:273"
            (luaDispatcher "window.resize()")
            { mouse = true; }
          ];
        }
      ];

      workspace_rule = let
        chromium = lib.getExe pkgs.chromium;
        mattermost = lib.getExe pkgs.mattermost-desktop;
        qq = "${pkgs.qq}/bin/qq";
        steam = lib.getExe pkgs.steam;
      in [
        { workspace = void; default = true; default_name = "void"; }
        { workspace = browser; on_created_empty = chromium; default_name = "browser"; }
        { workspace = chat; on_created_empty = mattermost; default_name = "chat"; }
        { workspace = QQ; on_created_empty = qq; default_name = "QQ"; }
        { workspace = Steam; on_created_empty = steam; default_name = "Steam"; }
      ];
    };
  };
}
