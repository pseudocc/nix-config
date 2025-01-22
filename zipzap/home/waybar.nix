# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  home.packages = with pkgs; [ wireplumber ];
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.default = let
      escape = builtins.fromJSON;
    in {
      layer = "top";
      position = "bottom";
      mod = "dock";
      gtk-layer-shell = true;
      passthrough = false;

      modules-left = [
        "backlight"
        "tray"
        "clock"
        "hyprland/workspaces"
      ];

      modules-center = [ "hyprland/window" ];

      modules-right = [
        "network"
        "group/audio"
        "group/hardware"
      ];

      "group/hardware" = {
        orientation = "horizontal";
        modules = [
          "cpu"
          "memory"
          "battery"
        ];
      };

      "group/audio" = {
        orientation = "horizontal";
        modules = [
          "pulseaudio"
          "pulseaudio#microphone"
        ];
      };

      tray.spacing = 10;

      "hyprland/window" = {
        max-length = 60;
        separate-output = true;
      };

      clock = {
        format = escape ''"\uf017 {:%R  \uf133 %y/%m/%d}"'';
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = [
          (escape ''"\udb80\udcde"'')
          (escape ''"\udb80\udcdf"'')
          (escape ''"\udb80\udce0"'')
        ];
        min-length = 6;
      };

      battery = {
        states = {
          good = 95;
          warning = 30;
          critical = 20;
        };
        format = "{icon} {capacity}%";
        format-charging = escape ''"\udb80\udc84 {capacity}%"'';
        format-plugged = escape ''"\ueb2d {capacity}%"'';
        format-alt = "{time} {icon}";
        format-icons = [
          (escape ''"\udb80\udc8e"'')
          (escape ''"\udb80\udc7a"'')
          (escape ''"\udb80\udc7b"'')
          (escape ''"\udb80\udc7c"'')
          (escape ''"\udb80\udc7d"'')
          (escape ''"\udb80\udc7e"'')
          (escape ''"\udb80\udc7f"'')
          (escape ''"\udb80\udc80"'')
          (escape ''"\udb80\udc81"'')
          (escape ''"\udb80\udc82"'')
          (escape ''"\udb80\udc79"'')
        ];
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        tooltip = false;
        format-muted = escape ''"\udb81\udf5f Muted"'';
        on-click = "pamixer -t";
        on-scroll-up = "pamixer -i 5";
        on-scroll-down = "pamixer -d 5";
        scroll-step = 5;
        format-icons = {
          headphone = escape ''"\udb80\udecb"'';
          hands-free = escape ''"\udb80\udecb"'';
          headset = escape ''"\udb80\udece"'';
          phone = escape ''"\uf095"'';
          portable = escape ''"\uf10b"'';
          car = escape ''"\uf1b9"'';
          default = [
            (escape ''"\udb81\udd7f"'')
            (escape ''"\udb81\udd80"'')
            (escape ''"\udb81\udd7e"'')
          ];
        };
      };

      "pulseaudio#microphone" = {
        format = "{format_source}";
        format-source = escape ''"\udb80\udf6c {volume}%"'';
        format-source-muted = escape ''"\udb80\udf6d Muted"'';
        on-click = "pamixer --default-source -t";
        on-scroll-up = "pamixer --default-source -i 5";
        on-scroll-down = "pamixer --default-source -d 5";
        scroll-step = 5;
      };

      network = {
        format = "{ifname}";
        format-ethernet = escape ''"\uf0c1 {ipaddr}/{cidr}"'';
        format-wifi = escape ''"\uf1eb {essid} ({signalStrength}%)"'';
        format-disconnected = "busted";
        tooltip-format = escape ''"\udb81\udef3 {ifname} via {gwaddr}"'';
        tooltip-format-ethernet = escape ''"\uf0c1 {ifname}"'';
        tooltip-format-wifi = escape ''"\uf1eb {essid} ({signalStrength}%)"'';
        tooltip-format-disconnected = "Disconnected";
        max-length = 50;
      };

      cpu = {
        interval = 10;
        max-length = 10;
        format = escape ''"\uf4bc {}%"'';
      };

      memory = {
        interval = 10;
        max-length = 10;
        format = escape ''"\ue266 {}%"'';
      };
    };

    style = with flakes.colors; ''
      @define-color base transparent;
      @define-color surface #${surface};
      @define-color inactive #${bright.black};
      @define-color highlight #${highlight};
      @define-color clock #${yellow};
      @define-color network #${bright.yellow};
      @define-color sound #${blue};
      @define-color microphone #${magenta};
      @define-color battery #${green};
    '' + builtins.readFile ./waybar.css;
  };
}

