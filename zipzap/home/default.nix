# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, modulesPath, ... }: let
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
    flakes.homeManagerModules.ghostty
    flakes.catppuccin.homeModules.catppuccin
  ];

  nixpkgs.overlays = [
    (final: prev: {
      chromium = prev.chromium.override {
        commandLineArgs = "--enable-wayland-ime";
      };
      unstable = import flakes.nixpkgs-mine { inherit (pkgs) system; };
    })
  ];

  home = {
    username = flakes.me.user;
    homeDirectory = "/home/${flakes.me.user}";

    sessionVariables = {
      NIXOS_OZONE_WL = 1;
      XCURSOR_SIZE = cursor.size;
      XCURSOR_THEME = cursor.name;
    };

    packages = with pkgs; [
      zig
      zig-shell-completions
      wl-clipboard
    ];
  };

  gtk = {
    enable = true;

    cursorTheme = cursor;

    iconTheme = {
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
    ghostty.enable = false;
  };

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-gtk
      fcitx5-configtool
      fcitx5-chinese-addons
      fcitx5-pinyin-zhwiki
    ];
  };

  programs = {
    home-manager.enable = true;
    gh.enable = true;
    bun.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "25.05";
}
