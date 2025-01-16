# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, modulesPath, ... }: {
  disabledModules = [
    "${modulesPath}/programs/ghostty.nix"
  ];

  imports = [
    ./hyprland.nix
    ./ghostty.nix
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
      chromium
    ];
  };

  gtk.enable = true;

  catppuccin = {
    enable = true;
    ghostty.enable = false;
    gtk = {
      enable = true;
      size = "standard";
    };
    cursors = {
      enable = true;
      accent = "peach";
    };
  };

  programs = {
    bash.enable = true;
    home-manager.enable = true;
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  programs.git = {
    enable = true;
    extraConfig = {
      user = { inherit (flakes.me) nick name email signingKey; };
      init.defaultBranch = "main";
      alias = {
        root = "rev-parse --show-toplevel";
      };
      pull.rebase = true;
      gpg.program = lib.getExe' pkgs.gnupg "gpg2";
      commit.gpgSign = true;
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
