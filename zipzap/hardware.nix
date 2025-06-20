# vim: et:ts=2:sw=2
{ pkgs, flakes, ... }: {
  boot.initrd.luks.devices."luks-bd93f785-372d-410e-8222-741255fc9115".device = "/dev/disk/by-uuid/bd93f785-372d-410e-8222-741255fc9115";
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [
    "console=tty1"
  ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/eea6c913-1a36-4c54-a235-f4c6d39eb5d2";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/3B38-D71C";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.graphics.enable = true;
  hardware.enableRedistributableFirmware = true;
  hardware.firmware = with pkgs; [
    wireless-regdb
  ];
  hardware.cpu.intel.updateMicrocode = true;
  services.fprintd.enable = false;

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;
}
