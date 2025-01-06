{ lib, pkgs, constants, ... }: {
  # You can import other home-manager modules here
  imports = [
    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
    ./hyprland.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = false;
    };
  };

  home = {
    username = constants.user.name;
    homeDirectory = "/home/${constants.user.name}";

    sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };

    packages = with pkgs; [
      chromium
    ];
  };

  programs = {
    bash.enable = true;
    kitty.enable = true;
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
    extraConfig = constants.git // {
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
