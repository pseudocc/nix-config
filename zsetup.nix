{ lib, pkgs, config, flakes, ... }:
with lib;
let cfg = config.zsetup;
in {
  options.zsetup = {
    pipewire = mkEnableOption "sound with PipeWire";
    cups = mkEnableOption "CUPS to print documents";
    desktop = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = "Whether desktop environment is present.";
    };
    session = mkOption {
      type = with types; nullOr path;
      default = null;
      example = "/nix-store/share/wayland-sessions";
      description = "The session tuigreet will launch.";
    };
  };

  config = {
    services.printing.enable = cfg.cups;

    hardware.pulseaudio.enable = !cfg.pipewire;
    security.rtkit.enable = cfg.desktop;
    services.pipewire = mkIf cfg.pipewire {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    services.greetd = mkIf (cfg.desktop && cfg.session != null) {
      enable = true;
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
} 
