# vim: et:ts=2:sw=2
{ lib, pkgs, config, flakes, ... }: let
in {
  programs.ssh = {
    enable = true;
    includes = [ "unmanaged-config" ];
    addKeysToAgent = "confirm";
    matchBlocks = {
      "github.com".identityFile = "~/.ssh/self";
      mock = {
        hostname = "mock.local";
        user = "u";
      };
      p900 = {
        hostname = "p900.local";
        user = flakes.me.user;
      };
    };
  };
}
