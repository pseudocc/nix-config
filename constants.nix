let
  editor.exe = "nvim";
  editor.pkg = "neovim";
  me.nick = "pseudoc";
  me.github = "pseudocc";
  me.name = "Atlas Yu";
  me.email = "pseudoc@163.com";
in {
  user = {
    name = me.nick;
    description = "Real vim enthusiast.";
    authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINuoseDzo0mUwBthHFnKfNPK1EdJTrpv7boeC1ybMsty pseudoc@nixos"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAUH3ybKRS1BOKcW7dngfm1YZ01tDKMqWaFf4uxzaiGG pseudoc@general"
    ];
  };

  git = {
    core.editor = editor.exe;
    user = {
      inherit (me) nick name email;
      signingkey = "05D58E6C4E4A2052";
    };
    init.defaultBranch = "main";
    alias = {
      root = "rev-parse --show-toplevel";
    };
    pull.rebase = true;
  };

  colors = {
    background = "#272120";
    foreground = "#ddbfb9";
    cursor = "#ffafa2";

    black = "#413736";
    red = "#db475f";
    green = "#6ead47";
    yellow = "#c68c2e";
    blue = "#5a9bec";
    magenta = "#c36ee7";
    cyan = "#33acac";
    white = "#cfc4c2";

    bright = {
      black = "#756764";
      red = "#ed6677";
      green = "#7fc453";
      yellow = "#dfa13e";
      blue = "#7cb1f5";
      magenta = "#d18fef";
      cyan = "#3dc4c4";
      white = "#f8f6f6";
    };
  };
}
