{ pkgs, flakes, modulesPath, ... }:

{
  imports = [
    flakes.lanzaboote.nixosModules.lanzaboote
    (modulesPath + "/hardware/cpu/intel-npu.nix")
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "cryptd" ];
  boot.initrd.luks.devices."cryptroot".device = "/dev/disk/by-label/NIXLUKS";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "console=tty1" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [{ device = "/dev/disk/by-label/NIXSWAP"; }
    ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.npu.enable = true;
  hardware.cpu.intel.updateMicrocode = true;
  hardware.enableRedistributableFirmware = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;

  hardware.ipu7 = {
    enable = true;
    platform = "ipu7x";
  };
  zsetup.unfree = [
    "ipu7-camera-bins"
    "ipu7-camera-bins-unstable"
    "ivsc-firmware"
    "ivsc-firmware-unstable"
  ];
}
