# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }:
{
  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user = { inherit (flakes.me) nick name email signingKey; };
      init.defaultBranch = "main";
      alias = {
        root = "rev-parse --show-toplevel";
      };
      pull.rebase = true;
      gpg.program = lib.getExe' pkgs.gnupg "gpg2";
      commit.gpgSign = true;
      url = {
        "git+ssh://pseudoc@git.launchpad.net/".insteadOf = "lp:";
        "git@github.com:".insteadOf = "gh:";
      };
    };
  };

  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 1800;
    enableSshSupport = true;
    pinentry.package = pkgs.pinentry-rofi;
  };
}
