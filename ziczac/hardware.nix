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
    ipu7-drivers = prev.ipu7-drivers.overrideAttrs (old: rec {
      version = "20260926_1900_40";
      src = pkgs.fetchFromGitHub {
        owner = "intel";
        repo = "ipu7-drivers";
        tag = version;
        hash = "sha256-JdCtc+BWp9BlhyilVTwpBEWw4zxk/2VfaYfgX0O+vzw=";
      };
      patches = (old.patches or [ ]) ++ [
        (pkgs.fetchpatch {
          url = "https://github.com/intel/ipu7-drivers/pull/120.patch";
          hash = "sha256-J+16bzLhrQ8/FTAaCLSUvbi9DjaWRkP7T8sq+DHBg+g=";
        })
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

  # The Piano 2 times out after switching to LE 2M on this Intel controller.
  # Prefer LE 1M without changing the keyboard firmware or other PHY choices.
  services.udev.extraRules = ''
    SUBSYSTEM=="bluetooth", ENV{DEVTYPE}=="host", KERNEL=="hci0", KERNELS=="0000:00:14.7", TAG+="systemd", ENV{SYSTEMD_WANTS}+="bluetooth-phy.service"
  '';

  systemd.services.bluetooth-phy = {
    description = "Prefer LE 1M PHY on the Intel Bluetooth controller";
    wantedBy = [ "bluetooth.service" ];
    after = [ "bluetooth.service" ];

    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "420s";
    };

    script = ''
      expected=(
        BR1M1SLOT BR1M3SLOT BR1M5SLOT
        EDR2M1SLOT EDR2M3SLOT EDR2M5SLOT
        EDR3M1SLOT EDR3M3SLOT EDR3M5SLOT
        LE1MTX LE1MRX LECODEDTX LECODEDRX
      )

      selected_matches() {
        local output line
        local -a selected
        output="$(${pkgs.bluez}/bin/btmgmt --timeout 3 --index 0 phy 2>/dev/null)" || true
        line="$(printf '%s\n' "$output" | sed -n 's/^Selected phys: *//p')"
        read -r -a selected <<< "$line"
        [[ "''${selected[*]}" == "''${expected[*]}" ]]
      }

      # btmgmt can report failure while returning success, so verify the mask.
      for attempt in {1..30}; do
        # Do not change a different adapter if it happens to be named hci0.
        if [[ -d /sys/devices/pci0000:00/0000:00:14.7/bluetooth/hci0 ]]; then
          info="$(${pkgs.bluez}/bin/btmgmt --timeout 3 --index 0 info 2>/dev/null)" || true
          if printf '%s\n' "$info" | grep -qE '^[[:space:]]*current settings:.*[[:space:]]powered([[:space:]]|$)'; then
            if selected_matches; then
              exit 0
            fi
            ${pkgs.bluez}/bin/btmgmt --timeout 3 --index 0 phy "''${expected[@]}" || true
            if selected_matches; then
              exit 0
            fi
          fi
        fi
        sleep 1
      done

      echo "Could not verify the requested hci0 PHY selection" >&2
      exit 1
    '';
  };

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
