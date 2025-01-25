# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs = {
    fzf.enable = true;
    command-not-found.enable = true;
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
    };
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
        "git-auto-fetch"
        "starship"
        "starship-vi-mode"
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
        "ls *"
        "git commit -m *"
        "cp *"
        "pkill *"
      ];
    };
  };
}

