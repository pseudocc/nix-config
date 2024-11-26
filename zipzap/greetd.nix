{ lib, pkgs, constants, ... }:
let
  tuigreet = lib.getExe pkgs.greetd.tuigreet;
  hyprland-session = "${pkgs.hyprland}/share/wayland-sessions";
in {
  services.greetd = {
    enable = true;
    vt = 2;
    settings = {
      default_session = {
        command = "${tuigreet} --time --remember --remember-session --sessions ${hyprland-session}";
        user = "${constants.user.name}";
      };
    };
  };
}
