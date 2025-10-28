# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      {
        output.criteria = "eDP-1";
        output.scale = 1.0;
      }
      {
        profile.name = "portable";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
          }
        ];
      }
      { include = "~/.config/kanshi/docked"; }
    ];
  };

  home.file.".config/kanshi/external".text = ''
    profile docked {
      output "eDP-1" disable
      output "HDMI-A-1" enable
    }
  '';

  home.file.".config/kanshi/internal".text = "";

  home.file.".config/kanshi/both".text = ''
    profile docked {
      output "eDP-1" enable
      output "HDMI-A-1" enable position 0,0
    }
  '';

  wayland.windowManager.hyprland.settings.source = [
    # This file is not managed by Nix
    "~/.config/hypr/kanshi.conf"
  ];

  home.packages = let
    systemctl = lib.getExe' pkgs.systemd "systemctl";
    monps = pkgs.writeShellScriptBin "monps" ''
      COMMAND="''${1:-reload}"

      enable-monitor() {
        local kanshi hyprland
        kanshi="include \"~/.config/kanshi/$1\""

        echo "$kanshi" > ~/.config/kanshi/docked
        ${systemctl} --user restart kanshi.service

        hyprland="monitor = ,preferred,auto"
        if [ "$1" = "both" ] && [ "$2" = "mirror" ]; then
          hyprland="$hyprland,auto,mirror,eDP-1"
        else
          hyprland="$hyprland,1"
        fi
        echo "$hyprland" > ~/.config/hypr/kanshi.conf
      }

      case "$COMMAND" in
        r|reload)
          ${systemctl} --user restart kanshi.service
          ;;
        m|mirror)
          enable-monitor both mirror
          ;;
        j|joint)
          enable-monitor both
          ;;
        i|internal)
          enable-monitor internal
          ;;
        e|external)
          enable-monitor external
          ;;
        *)
          echo "Usage: monps [reload|mirror|joint|internal|external]"
          exit 1
          ;;
      esac
    '';
  in [
    monps
  ];
}
