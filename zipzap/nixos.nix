# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  imports = [
    ../zsetup.nix
    ./hardware.nix

    flakes.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
    flakes.home-manager.nixosModules.home-manager
    flakes.catppuccin.nixosModules.catppuccin
  ];

  home-manager = {
    extraSpecialArgs = { inherit pkgs-unstable flakes; };
    users.${flakes.me.user} = import ./home/default.nix;
  };

  networking.hostName = "zipzap";
  time.timeZone = "Asia/Shanghai";

  environment.systemPackages = with pkgs; [
    openvpn
  ];

  zsetup = {
    pipewire = true;
    cups = true;
    desktop = pkgs.gtk4.dev;
    session = "${pkgs.hyprland}/share/wayland-sessions";
  };
}
