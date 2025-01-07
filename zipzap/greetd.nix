{ lib, pkgs, flakes, ... }:
let
  tuigreet = lib.getExe pkgs.greetd.tuigreet;
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
in {
  services.greetd = {
    enable = true;
    vt = 6;
    settings = {
      default_session = {
        command = "${tuigreet} -t -s ${hyprland-session}";
        user = "${flakes.me.user}";
      };
    };
  };
}
