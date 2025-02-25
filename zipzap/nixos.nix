# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }: {
  imports = [
    ../zsetup.nix
    ./hardware.nix

    flakes.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
    flakes.home-manager.nixosModules.home-manager
    flakes.catppuccin.nixosModules.catppuccin
    flakes.intel-npu-driver.nixosModules.intel-npu-driver
  ];

  home-manager = {
    extraSpecialArgs = { inherit flakes; };
    users.${flakes.me.user} = import ./home/default.nix;
  };

  networking.hostName = "zipzap";
  time.timeZone = "Asia/Shanghai";

  environment.systemPackages = with pkgs; [
    openvpn
  ];

  zsetup = {
    pipewire = true;
    locations = "all";
    desktop = pkgs.gtk4.dev;
    session = "${pkgs.hyprland}/share/wayland-sessions";
  };
}
