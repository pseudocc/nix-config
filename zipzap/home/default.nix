# vim: et:ts=2:sw=2
{ nixosConfig, lib, pkgs, zsetup, flakes, modulesPath, ... }: let
  cursor = {
    name = "Bibata-Modern-Ice";
    size = 24;
    package = pkgs.bibata-cursors;
  };
in {
  disabledModules = [
    "${modulesPath}/programs/ghostty.nix"
  ];

  imports = [
    ./hyprland.nix
    ./ghostty.nix
    ./git.nix
    ./zsh.nix
    ./nixvim.nix
    ./ssh.nix
    ./opencode.nix
    flakes.modules.ghostty
    flakes.catppuccin.homeModules.catppuccin
    flakes.nix-index-database.homeModules.default
    flakes.hypriio.homeModules.default
  ];

  nixpkgs.overlays = [
    (final: prev: let
      system = prev.stdenv.hostPlatform.system;
    in {
      chromium = prev.chromium.override {
        commandLineArgs = "--enable-wayland-ime";
      };
      hypriio = flakes.hypriio.packages.${system}.default;
      unstable = import flakes.nixpkgs-unstable {
        inherit (pkgs.stdenv.hostPlatform) system;
      };
    })
  ];

  xdg.configFile."rofi/config.rasi".source = ./rofi.rasi;

  nixpkgs.config = { inherit (nixosConfig.nixpkgs.config) allowUnfreePredicate; };

  home = {
    username = flakes.me.user;
    homeDirectory = "/home/${flakes.me.user}";

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      XCURSOR_SIZE = cursor.size;
      XCURSOR_THEME = cursor.name;
    };

    packages = let
      zig = pkgs.zig;
      default-cc = pkgs.writeShellScriptBin "cc" ''
        exec ${zig}/bin/zig cc "$@"
      '';
    in with pkgs; [
      zig
      zig-shell-completions
      default-cc
      rustc
      cargo
      wl-clipboard
      qbittorrent-enhanced
      unstable.devenv
    ];
  };

  gtk = {
    enable = true;

    cursorTheme = cursor;

    iconTheme = lib.mkForce {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = {
      name = "catppuccin-mocha-peach-standard";
      package = pkgs.catppuccin-gtk.override {
        accents = [ "peach" ];
        size = "standard";
        variant = "mocha";
      };
    };
  };

  catppuccin = {
    enable = true;
    autoEnable = true;
    ghostty.enable = false;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      qt6Packages.fcitx5-configtool
      qt6Packages.fcitx5-chinese-addons
      fcitx5-pinyin-zhwiki
    ];
    fcitx5.settings.addons = {
      pinyin.globalSection = {
        PageSize = 6;
        CloudPinyinEnabled = "True";
        CloudPinyinIndex = 2;
      };
      cloudpinyin.globalSection.Backend = "Baidu";
    };
    fcitx5.settings.inputMethod = {
      GroupOrder."0" = "Default";
      "Groups/0" = {
        "Default Layout" = "us";
        DefaultIM = "pinyin";
        Name = "Default";
      };
      "Groups/0/Items/0".Name = "keyboard-us";
      "Groups/0/Items/1".Name = "pinyin";
    };
    fcitx5.settings.globalOptions = {
      "Hotkey/TriggerKeys"."0" = "Super+space";
    };
    fcitx5.waylandFrontend = true;
  };

  programs = {
    home-manager.enable = true;
    gh.enable = true;
    bun.enable = true;
    direnv.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "26.05";
}
