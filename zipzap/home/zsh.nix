# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs = {
    fzf.enable = true;
    nix-index = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  services.gpg-agent.enableZshIntegration = true;

  home.packages = with pkgs; [
    zsh-vi-mode
    any-nix-shell
  ];

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

    autocd = true;
    dirHashes = {
      dl = "$HOME/Downloads";
      gh = "$HOME/projects/github";
      l = "$HOME/projects/local";
      p = "$HOME/projects";
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "bun"
        "gh"
        "fzf"
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
      "..git" = "cd $(git rev-parse --show-toplevel)";
      "rebuild" = "sudo nixos-rebuild --flake /etc/nixos#$HOST";
    };

    history = {
      size = 2000;
      ignoreAllDups = true;
      ignorePatterns = [
        "rm *"
        "cd *"
        "ls *"
        "git commit -m *"
        "git commit -am *"
        "cp *"
        "pkill *"
      ];
    };

    initContent = ''
      . ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
      ${lib.getExe pkgs.any-nix-shell} zsh --info-right | source /dev/stdin
    '';
  };

  home.file.".profile".text = ''
    . $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
  '';
}

