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
    unfree = mkOption {
      type = with types; listOf types.str;
      default = [ ];
      example = [ "steam" "vault" ];
      description = "List of unfree packages to allow.";
    };
  };

  config = let
    locations = if cfg.locations == "all" then all.locations else cfg.locations;

    home = mkIf (builtins.elem "home" locations) {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        fontPackages = with pkgs; lib.mkForce [
          noto-fonts-color-emoji
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif
          noto-fonts
        ];
      };
      zsetup.unfree = [
        "qq"
        "discord"
        "steam"
        "steam-original"
        "steam-unwrapped"
        "steam-run"
        "github-copilot-cli"
      ];
    };

    office = mkIf (builtins.elem "office" locations) {
      virtualisation.incus = {
        enable = true;
        preseed.profiles = [
          {
            name = "ubuntu-dev";
            config."cloud-init.user-data" = ''
#cloud-config
              package_upgrade: true
              packages:
                - bash-completion
                - build-essential
                - debhelper
                - devscripts
                - openssh-server
                - git
                - curl
                - wget
                - vim
                - gnupg
                - gnupg-agent
              runcmd:
                - [ sh, -c, "curl -sS https://starship.rs/install.sh | sh -s -- -y" ]
              write_files:
                - path: /home/pseudoc/.bashrc
                  content: |
                    # ~/.bashrc: executed by bash(1) for non-login shells.
                    . "$HOME/.bash_profile"
                - path: /home/pseudoc/.bash_profile
                  content: |
                    # ~/.bash_profile: executed by bash(1) for login shells.
                    # if not running interactively, don't do anything
                    [[ $- != *i* ]] && return

                    if [ -f /etc/bash_completion ]; then
                      . /etc/bash_completion
                    fi
                    if [ -f /usr/share/bash-completion/bash_completion ]; then
                      . /usr/share/bash-completion/bash_completion
                    fi

                    case $TERM in
                      xterm-kitty|xterm-ghostty)
                        export TERM="xterm-256color"
                        ;;
                    esac

                    # Vim way
                    export EDITOR=vim
                    set -o vi
                    alias vi='vim'

                    # Starship prompt
                    eval "$(starship init bash)"

                    # Debian development
                    export DEBEMAIL="atlas.yu@canonical.com"
                    export DEBFULLNAME="Atlas Yu"

                    # GPG signing
                    export GPG_TTY=$(tty)
              users:
                - name: pseudoc
                  ssh_authorized_keys:
                    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuoseDzo0mUwBthHFnKfNPK1EdJTrpv7boeC1ybMsty pseudoc@nixos
                  sudo: ALL=(ALL) NOPASSWD:ALL
                  shell: /bin/bash
              '';
           }
        ];
      };
      security.wrappers.incus = {
        setuid = true;
        owner = "root";
        group = "incus-admin";
        source = lib.getExe pkgs.incus;
      };
      services.printing = {
        enable = true;
        drivers = with pkgs; [ hplip ];
      };
      hardware.printers.ensurePrinters = [{
        name = "hp-laserjet";
        description = "HP LaserJet 500 colorMFP M570dw";
        location = "Beijing Office";
        deviceUri = "socket://hp-laserjet.local";
        model = "HP/hp-laserjet_500_color_mfp_m575-ps.ppd.gz";
        ppdOptions.pageSizes = "A4";
      }];
      networking.hosts = {
        "10.106.0.106" = [
          "hp-laserjet.local"
          "printer.local"
        ];
        "10.106.0.76" = [ "mock.local" ];
        "10.106.4.112" = [ "mock.local" ];
      };
      environment.systemPackages = [
        pkgs.vault
        pkgs.rclone
      ];
      zsetup.unfree = [
        "vault"
      ];
    };

    sound = {
      services.pulseaudio.enable = !cfg.pipewire;
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
        useTextGreeter = true;
        settings = {
          default_session = let
            tuigreet = lib.getExe pkgs.tuigreet;
          in {
            command = "${tuigreet} -t -s ${cfg.session}";
            user = "${flakes.me.user}";
          };
        };
      };
    };

  in mkMerge [
    {
      nixpkgs.overlays = [
        (final: prev: let
          unstable = import flakes.nixpkgs-unstable {
            inherit (pkgs.stdenv.hostPlatform) system;
            config.allowUnfreePredicate = _pkgs: builtins.elem (lib.getName _pkgs) cfg.unfree;
          };
        in {
          inherit (unstable)
            steam
            steam-original
            steam-unwrapped
            steam-run;
        })
      ];

      services.fwupd.enable = true;
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          userServices = true;
          domain = true;
          hinfo = true;
        };
      };
      services.journald = {
        extraConfig = ''
          SystemMaxUse=200M
        '';
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
        p7zip
        github-copilot-cli
      ];

      nixpkgs.config.allowUnfreePredicate = _pkgs: builtins.elem (lib.getName _pkgs) cfg.unfree;
    }

    home
    office
    sound
    desktop
  ];
}
