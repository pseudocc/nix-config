# vim: et:ts=2:sw=2
{ lib, pkgs, config, flakes, ... }:
with lib; let
  cfg = config.zsetup;
  desktopType = types.nullOr types.package;
in {
  options.zsetup = {
    pipewire = mkEnableOption "sound with PipeWire";
    cups = mkEnableOption "CUPS to print documents";
    desktop = mkOption {
      type = desktopType;
      default = null;
      example = "gtk4";
      description = "Which desktop environment is using.";
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
    services.fwupd.enable = true;

    hardware.pulseaudio.enable = !cfg.pipewire;
    security.rtkit.enable = cfg.desktop != null;
    services.pipewire = mkIf cfg.pipewire {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = with pkgs; let
      additionals = if cfg.desktop != null then [ cfg.desktop ] else [];
    in [
      python3
      nodejs
      usbutils
      vim
      tmux
      tree
      curl
      wget
      ripgrep
      pamixer
    ] ++ additionals;
    programs.dconf.enable = cfg.desktop != null;

    services.greetd = mkIf (cfg.desktop != null && cfg.session != null) {
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

    services.avahi = {
      enable = true;
      nssmdns4 = true;
    };
  };
} 
