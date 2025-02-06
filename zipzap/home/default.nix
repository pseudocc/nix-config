# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, modulesPath, ... }: let
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
    };

    packages = with pkgs; [
      zig
      zig-shell-completions
      wl-clipboard
    ];
  };

  gtk.enable = true;

  catppuccin = {
    enable = true;
    ghostty.enable = false;
    cursors = {
      enable = true;
      accent = "peach";
    };
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
