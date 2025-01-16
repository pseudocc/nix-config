# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, modulesPath, ... }: {
  disabledModules = [
    "${modulesPath}/programs/ghostty.nix"
  ];

  imports = [
    ./hyprland.nix
    ./ghostty.nix
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

  programs.ghostty = {
    enable = true;
    settings = let
      colors = flakes.colors;
    in {
      # Appearance
      window-decoration = false;
      gtk-tabs-location = "bottom";
      font-feature = "-calt";
      background-image = toString (builtins.fetchurl {
        url = "file://${toString ./assets/termbg.png}";
        sha256 = "sha256:0i71x40hgiy1hxx0y8bh3lq6zzsckndfq18qbhq5g1pwd5ggnyai";
      });
      background = colors.base;

      palette = lib.imap0 (n: color: "${toString n}=${color}") [
        colors.black
        colors.red
        colors.green
        colors.yellow
        colors.blue
        colors.magenta
        colors.cyan
        colors.white
        colors.bright.black
        colors.bright.red
        colors.bright.green
        colors.bright.yellow
        colors.bright.blue
        colors.bright.magenta
        colors.bright.cyan
        colors.bright.white
      ];
      cursor-color = colors.cursor;
      cursor-text = colors.surface;
      selection-foreground = colors.highlight;
      selection-background = colors.bright.black;

      # Controls
      keybind = let 
        binds = lib.mapAttrsToList;
        bind = key: act: "${key}=${act}";
        primary = key: bind "ctrl+shift+${key}";
        secondary = key: bind "ctrl+alt+${key}";
        combo = leader: key: bind "ctrl+shift+${leader}>${key}";
        escape = "ignore";
      in
        [] # [ "clear" ]
        ++ binds primary {
          w = "close_surface";
          c = "copy_to_clipboard";
          v = "paste_from_clipboard";
          p = "paste_from_selection";

          enter = "new_tab";
          t = "toggle_tab_overview";
          left = "previous_tab";
          right = "next_tab";
          end = "last_tab";
          home = "goto_tab:1";
          up = "move_tab:-1";
          down = "move_tab:1";
        }
        ++ binds secondary {
          enter = "new_split:auto";
          h = "new_split:left";
          j = "new_split:down";
          k = "new_split:up";
          l = "new_split:right";
          t = "toggle_split_zoom";
          left = "goto_split:left";
          right = "goto_split:right";
          up = "goto_split:up";
          down = "goto_split:down";
          page_up = "goto_split:previous";
          page_down = "goto_split:next";
        }
        ++ binds (combo "f") {
          inherit escape;
          up = "increase_font_size:1";
          down = "decrease_font_size:1";
          right = "increase_font_size:4";
          left = "decrease_font_size:4";
          page_up = "increase_font_size:8";
          page_down = "decrease_font_size:8";
          r = "reset_font_size";
        }
        ++ binds (combo "s") {
          inherit escape;
          c = "clear_screen";
          a = "select_all";
          home = "scroll_to_top";
          end = "scroll_to_bottom";
          page_up = "scroll_page_up";
          page_down = "scroll_page_down";
          u = "scroll_page_fractional:-0.5";
          d = "scroll_page_fractional:+0.5";
          up = "scroll_page_lines:-1";
          down = "scroll_page_lines:+1";
          left = "scroll_page_lines:-4";
          right = "scroll_page_lines:+4";
        };
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
