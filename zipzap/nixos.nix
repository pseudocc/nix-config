{ lib, pkgs, flakes, ... }: {
  imports = [
    ../zsetup.nix
    ./hardware.nix

    flakes.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
    flakes.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = { inherit flakes; };
    users.${flakes.me.user} = import ./home/default.nix;
  };

  networking.hostName = "zipzap";
  time.timeZone = "Asia/Shanghai";

  zsetup = {
    pipewire = true;
    cups = true;
    desktop = true;
    session = "${pkgs.hyprland}/share/wayland-sessions";
  };
}
