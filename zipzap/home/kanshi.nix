# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  services.kanshi = {
    enable = true;
    systemdTarget = "hyprland-session.target";
    settings = [
      {
        output.criteria = "eDP-1";
        output.scale = 1.25;
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
      if [ $(hyprctl monitors | grep "^Monitor" | wc -l) != 2 ]; then
        echo "Only works with two monitors connected."
        exit 1
      fi

      COMMAND="''${1:-reload}"

      enable-monitor() {
        echo "include \"~/.config/kanshi/$1\"" > ~/.config/kanshi/docked
        restart-kanshi
      }

      restart-kanshi() {
        ${systemctl} --user restart kanshi.service
      }

      case "$COMMAND" in
        r|reload)
          restart-kanshi
          ;;
        m|mirror)
          enable-monitor "both"
          echo "monitor = ,preferred,auto,auto,mirror,eDP-1" > ~/.config/hypr/kanshi.conf
          ;;
        j|joint)
          enable-monitor "both"
          echo "" > ~/.config/hypr/kanshi.conf
          ;;
        i|internal)
          enable-monitor "internal"
          echo "" > ~/.config/hypr/kanshi.conf
          ;;
        e|external)
          enable-monitor "external"
          echo "" > ~/.config/hypr/kanshi.conf
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
