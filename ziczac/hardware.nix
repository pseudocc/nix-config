{ pkgs, lib, flakes, modulesPath, ... }:
let
  # Linux 7.3's Intel CVS layer needs the September HAL, whose proprietary
  # libraries require glibc >= 2.43. Keep the whole camera process on one
  # newer userspace, without replacing nixos-26.05's system-wide glibc.
  cameraPkgs = import flakes.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (pkgs) config;
    overlays = [
      (final: prev: {
        ipu7-camera-bins = final.callPackage
          (flakes.nixpkgs + "/pkgs/by-name/ip/ipu7-camera-bins/package.nix") { };
        ipu7x-camera-hal = final.callPackage
          (flakes.nixpkgs + "/pkgs/by-name/ip/ipu7x-camera-hal/package.nix") { };
      })
    ];
  };
  cameraGst = cameraPkgs.gst_all_1;
in
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

  boot.kernelPackages = pkgs.linuxPackages_latest.extend (_: prev: {
    # Match PSys's shared declarations to the unmodified in-tree IPU7 core.
    # The vendor-only bus fields otherwise corrupt memory during probe/use.
    ipu7-drivers = prev.ipu7-drivers.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ [
        ./patches/ipu7-psys-in-tree-core-abi.patch
      ];
    });
  });
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

  # The relay, GStreamer plugins, HAL and binaries must share the newer libc.
  nixpkgs.overlays = [
    (final: prev: {
      v4l2-relayd = cameraPkgs.v4l2-relayd;
    })
  ];

  services.v4l2-relayd.instances.ipu7.extraPackages = lib.mkForce [
    cameraGst.icamerasrc-ipu7x
  ];
  systemd.services.v4l2-relayd-ipu7.environment.GST_PLUGIN_PATH = lib.mkForce (
    # Scan only the plugins needed by the raw-camera relay. The HAL's linked
    # GStreamer libraries are resolved separately through their RPATHs.
    lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
      cameraGst.gst-plugins-base
      cameraGst.gst-plugins-good
      cameraGst.gstreamer.out
      cameraGst.icamerasrc-ipu7x
    ]
  );

  zsetup.unfree = [
    "ipu7-camera-bins"
    "ipu7-camera-bins-unstable"
    "ivsc-firmware"
    "ivsc-firmware-unstable"
  ];
}
