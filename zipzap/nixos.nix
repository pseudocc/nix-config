{ lib, pkgs, flakes, ... }: {
  imports = [
    ./hardware.nix
    ./greetd.nix

    flakes.nixos-hardware.nixosModules.lenovo-thinkpad-x13-yoga
    flakes.home-manager.nixosModules.home-manager
  ];

  home-manager = {
    extraSpecialArgs = { inherit flakes; };
    users = {
      # Import your home-manager configuration
      ${flakes.me.user} = import ./home/index.nix { inherit lib pkgs flakes; };
    };
  };

  networking.hostName = "zipzap";
  time.timeZone = "Asia/Shanghai";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
}
