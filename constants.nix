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
}
