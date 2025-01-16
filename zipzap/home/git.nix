# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }:
{
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
}
