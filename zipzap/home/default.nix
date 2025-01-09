# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  imports = [
    ./hyprland.nix
    ./ghostty.nix
  ];

  home = {
    username = flakes.me.user;
    homeDirectory = "/home/${flakes.me.user}";

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    packages = with pkgs; [
      chromium
    ];
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

  programs.ghostty = {
    enable = true;
    config = {
      window-decoration = false;
      gtk-tabs-location = "bottom";
      font-feature = "-clt";
      keybind = [
        "ctrl+z=close_surface"
        "ctrl+d=new_split:right"
      ];
    };
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
