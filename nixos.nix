# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  imports = [];

  nix = let
    flakeInputs = lib.filterAttrs (_: lib.isType "flake") flakes;
  in {
    settings = {
      experimental-features = "nix-command flakes";
      flake-registry = "";
      trusted-users = [ "root" flakes.me.user ];
      substituters = [
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
        "https://mirror.sjtu.edu.cn/nix-channels/store"
      ];
    };
    channel.enable = false;

    registry = lib.mapAttrs (_: flake: {inherit flake;}) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  boot.loader = {
    efi.canTouchEfiVariables = true;
  };
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  networking.useDHCP = lib.mkDefault true;
  networking.wireless.iwd = {
    enable = true;
    settings = {
      General.CountryCode = "HK";
    };
  };
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
    plugins = with pkgs; [
      networkmanager-openvpn
    ];
  };
  networking.nftables.enable = true;

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
    noto-fonts-color-emoji
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts
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

  system.stateVersion = "25.11";
}
