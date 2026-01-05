# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = let
      hyprctl = lib.getExe' pkgs.hyprland "hyprctl";
    in [
      { output.criteria = "eDP-1"; }
      {
        profile.name = "portable";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      {
        profile.name = "joint";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
          {
            criteria = "HDMI-A-1";
            status = "enable";
            position = "0,0";
          }
        ];
        profile.exec = [
          "${hyprctl} keyword monitor HDMI-A-1,highres,auto,auto"
        ];
      }
      {
        profile.name = "external-only";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "disable";
          }
          {
            criteria = "HDMI-A-1";
            status = "enable";
          }
        ];
        profile.exec = [
          "${hyprctl} keyword monitor HDMI-A-1,highres,auto,auto"
        ];
      }
      {
        profile.name = "internal-only";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
          {
            criteria = "HDMI-A-1";
            status = "disable";
          }
        ];
      }
      {
        profile.name = "mirror";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
          {
            criteria = "HDMI-A-1";
            status = "enable";
          }
        ];
        profile.exec = [
          "${hyprctl} keyword monitor HDMI-A-1,highres,auto,auto,mirror,eDP-1"
        ];
      }
    ];
  };
}
