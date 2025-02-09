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
    ./wofi.nix
    ./waybar.nix
    ./zsh.nix
    ./nixvim.nix
    flakes.homeManagerModules.ghostty
    flakes.catppuccin.homeManagerModules.catppuccin
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
    enabled = "fcitx5";
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
  home.stateVersion = "24.11";
}
