{ lib, pkgs, flakes, ... }: {
  imports = [
    ../zsetup.nix
    ./hardware.nix

    flakes.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
    flakes.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = { inherit flakes; };
    users.${flakes.me.user} = import ./home/default.nix { inherit lib pkgs flakes; };
  };

  services.greetd = let
    tuigreet = lib.getExe pkgs.greetd.tuigreet;
    session = "${pkgs.hyprland}/share/wayland-sessions";
  in {
    enable = true;
    vt = 6;
    settings = {
      default_session = {
        command = "${tuigreet} -t -s ${session}";
        user = "${flakes.me.user}";
      };
    };
  };

  networking.hostName = "zipzap";
  time.timeZone = "Asia/Shanghai";

  zsetup = {
    pipewire = true;
    cups = true;
    desktop = true;
  };
}
