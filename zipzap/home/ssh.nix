# vim: et:ts=2:sw=2
{ lib, pkgs, config, flakes, ... }: let
  canonical-bastion = host: {
    hostname = "${host}.canonical.is";
    user = flakes.me.canonical;
    proxyCommand = "${lib.getExe pkgs.cloudflared} access ssh --hostname %h";
  };
in {
  home.packages = [ pkgs.cloudflared ];
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
      ps7 = canonical-bastion "devices-bastion-ps7";
      pek = canonical-bastion "bjp-vpn1";
    };
  };
}
