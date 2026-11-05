# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  imports = [
    ../zsetup.nix
    ./hardware.nix

    flakes.nixos-hardware.nixosModules.lenovo-thinkpad-x1-yoga
    flakes.home-manager.nixosModules.home-manager
    flakes.catppuccin.nixosModules.catppuccin
    flakes.vinput.nixosModules.default
  ];

  home-manager = {
    extraSpecialArgs = { inherit flakes; };
    users.${flakes.me.user} = {
      imports = [ ./home/default.nix ];
      wayland.windowManager.hyprland.settings.bind = [{
        _args = [
          "SUPER + SHIFT + V"
          (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("vinput toggle")'')
        ];
      }];
    };
  };

  networking.hostName = "ziczac";
  time.timeZone = "Asia/Shanghai";

  programs.vinput = {
    enable = true;
    package = flakes.vinput.packages.${pkgs.stdenv.hostPlatform.system}.default;
    language = "en";
  };
  users.users.${flakes.me.user}.extraGroups = [ "ydotool" ];

  services.vinput-asr = {
    enable = true;
    device = "NPU";
    language = "en";
  };
  systemd.services.vinput-asr.serviceConfig.SupplementaryGroups = [ "render" ];

  security.pki.certificateFiles = [
    ./rootCA.pem
    ./mDNS.pem
  ];

  zsetup = {
    pipewire = true;
    locations = "all";
    desktop = pkgs.gtk4.dev;
    session = "${pkgs.hyprland}/share/wayland-sessions";
  };
}
