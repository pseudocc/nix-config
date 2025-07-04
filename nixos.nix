# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  imports = [];

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") flakes;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
    };
    channel.enable = false;

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  networking.useDHCP = lib.mkDefault true;
  networking.networkmanager.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.gohufont
    nerd-fonts.noto
    noto-fonts-emoji
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-extra
  ];

  users.users.${flakes.me.user} = {
    isNormalUser = true;
    description = flakes.me.description;
    extraGroups = [ "video" "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuoseDzo0mUwBthHFnKfNPK1EdJTrpv7boeC1ybMsty pseudoc@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUH3ybKRS1BOKcW7dngfm1YZ01tDKMqWaFf4uxzaiGG pseudoc@general"
    ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  security.sudo.extraRules = [{
    users = [ flakes.me.user ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  system.stateVersion = "25.05";
}
