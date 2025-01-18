# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  home.packages = with pkgs; [ wireplumber ];
  programs.waybar = {
    enable = true;
    settings.default = {
      layer = "top";
      position = "bottom";
      mod = "dock";
      gtk-layer-shell = true;

      modules-left = [
        "tray"
        "clock"
        "hyprland/workspaces"
      ];

      modules-center = [ "hyprland/window" ];

      modules-right = [
        "network"
        "wireplumber"
        "group/hardware"
        "backlight"
      ];

      tray.spacing = 10;

      "hyprland/window" = {
        max-length = 60;
        separate-output = true;
      };

      "hyprland/workspaces" = {
        format = "{id}";
      };

      clock = {
        format = "\\uf017 {:%R  \\uf133 %y/%m/%d}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      backlight = {
        device = "intel_backlight";
        format = "{icon} {percent}%";
        format-icons = [
          "\\udb80\\udcde"
          "\\udb80\\udcdf"
          "\\udb80\\udce0"
        ];
        min-length = 6;
      };

      "group/hardware" = {
        orientation = "horizontal";
        modules = [
          "cpu"
          "memory"
          "battery"
        ];
      };
    };
    style = ''
    '';
  };
}

