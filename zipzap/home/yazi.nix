{ config, lib, pkgs, flakes, ... }: let
  termfilechooser = pkgs.xdg-desktop-portal-termfilechooser.overrideAttrs {
    buildInputs = pkgs.xdg-desktop-portal-termfilechooser.buildInputs ++ [
      config.programs.yazi.package
      config.programs.ghostty.package
    ];
  };
  yazi-chooser-class = "com.pseudoc.yazi-chooser";
  yazi-chooser = pkgs.writeShellScriptBin "yazi-chooser" ''
    set -e
    multiple=$1
    directory=$2
    save=$3
    path=$4
    out=$5

    ghostty \
      --class=${yazi-chooser-class} \
      --title="$title" \
      --confirm-close-surface=false \
      -e yazi --chooser-file="$out" "$path"
  '';
in {
  programs.yazi.enable = true;

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      termfilechooser
    ];
    config = {
      hyprland = {
        default = [ "termfilechooser" "hyprland" ];
        "org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
      common.default = [ "termfilechooser" ];
    };
  };

  xdg.configFile."xdg-desktop-portal-termfilechooser/config".text = ''
    [filechooser]
    cmd=${lib.getExe yazi-chooser}
  '';

  wayland.windowManager.hyprland.settings.windowrulev2 = [
    "float,class:${yazi-chooser-class}"
    "size 60% 80%,class:${yazi-chooser-class}"
    "center,class:${yazi-chooser-class}"
  ];
}
