# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, modulesPath, ... }: {
  disabledModules = [
    "${modulesPath}/programs/ghostty.nix"
  ];

  imports = [
    ./hyprland.nix
    ./ghostty.nix
    ./git.nix
    ./wofi.nix
    ./waybar.nix
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
      wl-clipboard
      flakes.packages.neovim-terminal
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
    command-not-found.enable = true;
    fzf.enable = true;
    starship.enable = true;
    home-manager.enable = true;
    gh.enable = true;
    bun.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "bun"
        "gh"
        "fzf"
        "vi-mode"
        "git-prompt"
        "git-auto-fetch"
        "starship"
        "command-not-found"
        "history-substring-search"
        "dotenv"
      ];
    };

    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "rebuild" = "sudo nixos-rebuild --flake $HOME/nix-config#zipzap";
    };

    history = {
      size = 2000;
      ignoreAllDups = true;
      ignorePatterns = [
        "rm *"
        "cd *"
        "cp *"
        "pkill *"
      ];
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.11";
}
