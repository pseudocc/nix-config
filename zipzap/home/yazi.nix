{ config, lib, pkgs, flakes, ... }: let
  yazi = lib.getExe config.programs.yazi.package;
  ghostty = lib.getExe config.programs.ghostty.package;
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

    if [ "$multiple" = "1" ]; then
      if [ "$directory" = "1" ]; then
        title="Select Directories"
      else
        title="Select Files"
      fi
    elif [ "$directory" = "1" ]; then
      title="Select a Directory"
    elif [ "$save" = "1" ]; then
      title="Save File As"
    else
      title="Open File"
    fi

    ghostty \
      --class=${yazi-chooser-class} \
      --title="$title" \
      --confirm-close-surface=false \
      --window-decoration=client \
      -e yazi --chooser-file="$out" "$path"
  '';
  yazi-wrapped = pkgs.writeShellScriptBin "yazi-wrapped" ''
    if [ -t 1 ]; then
      exec ${yazi} "$@"
    else
      exec ${ghostty} -e ${yazi} "$@"
    fi
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

  xdg.desktopEntries.yazi-gui = {
    name = "Yazi (GUI)";
    exec = "${lib.getExe yazi-wrapped} %u";
    terminal = false;
    type = "Application";
    mimeType = [ "inode/directory" ];
  };

  xdg.mimeApps.defaultApplications = {
    "inode/directory" = [ "yazi-gui.desktop" ];
  };

  wayland.windowManager.hyprland.settings.windowrulev2 = [
    "float,class:${yazi-chooser-class}"
    "size 60% 80%,class:${yazi-chooser-class}"
    "center,class:${yazi-chooser-class}"
  ];
}
