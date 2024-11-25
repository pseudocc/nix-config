{ pkgs, constants, ... }: {
  # You can import other home-manager modules here
  imports = [
    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
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

    # packages = with pkgs; [];
  };

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    settings = {
      cursor.inactive_timeout = 5;
      input = {
        kb_layout = "us";
        touchpad = {
          natural_scroll = true;
        };
      };

      "$mod" = "SUPER";
      bind = [
        "$mod, T, exec, kitty"
      ];
    };
  };

  programs = {
    kitty.enable = true;
    git.enable = true;
    home-manager.enable = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
