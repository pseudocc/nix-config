# vim: et:ts=2:sw=2
{ lib, pkgs, config, flakes, ... }:
with lib; let
  cfg = config.zsetup;
  desktopType = types.nullOr types.package;
  enums = fields: with types; oneOf [
    (enum [ "all" ])
    (listOf (enum fields))
  ];
  all.locations = [ "office" "home" "mobile" ];
in {
  options.zsetup = {
    pipewire = mkEnableOption "sound with PipeWire";
    desktop = mkOption {
      type = desktopType;
      default = null;
      example = pkgs.gtk4;
      description = "Which desktop environment is using.";
    };
    locations = mkOption {
      type = enums all.locations;
      example = [ "home" ];
      description = "Where the system is used.";
    };
    session = mkOption {
      type = with types; nullOr path;
      default = null;
      example = "/nix-store/share/wayland-sessions";
      description = "The session tuigreet will launch.";
    };
  };

  config = let
    locations = if cfg.locations == "all" then all.locations else cfg.locations;

    office = mkIf (builtins.elem "office" locations) {
      services.printing = {
        enable = true;
        drivers = with pkgs; [ hplip ];
      };
      services.tor = {
        enable = true;
        openFirewall = true;
        client.enable = true;
        settings = {
          ContactInfo = flakes.me.email;
          Nickname = flakes.me.nick;
        };
      };
      hardware.printers.ensurePrinters = [{
        name = "hp-laserjet";
        description = "HP LaserJet 500 colorMFP M570dw";
        location = "Beijing Office";
        deviceUri = "socket://10.106.0.106";
        model = "HP/hp-laserjet_500_color_mfp_m575-ps.ppd.gz";
        ppdOptions.pageSizes = "A4";
      }];
    };

    sound = {
      hardware.pulseaudio.enable = !cfg.pipewire;
      security.rtkit.enable = cfg.desktop != null;
      services.pipewire = {
        enable = cfg.pipewire;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
      };

      environment.systemPackages = with pkgs; [
        pamixer
      ];
    };

    desktop = mkIf (cfg.desktop != null) {
      environment.systemPackages = [ cfg.desktop ];
      programs.dconf.enable = true;

      services.greetd = {
        enable = cfg.session != null;
        vt = 6;
        settings = {
          default_session = let
            tuigreet = lib.getExe pkgs.greetd.tuigreet;
          in {
            command = "${tuigreet} -t -s ${cfg.session}";
            user = "${flakes.me.user}";
          };
        };
      };
    };

  in mkMerge [
    {
      services.fwupd.enable = true;
      services.avahi = {
        enable = true;
        nssmdns4 = true;
      };
      environment.systemPackages = with pkgs; [
        python3
        nodejs
        usbutils
        vim
        tmux
        tree
        curl
        wget
        ripgrep
        nix-index
      ];
    }

    office
    sound
    desktop
  ];
}
