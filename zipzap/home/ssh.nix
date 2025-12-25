# vim: et:ts=2:sw=2
{ lib, pkgs, config, flakes, ... }: let
  canonical-bastion = host: {
    hostname = "${host}.canonical.is";
    user = flakes.me.canonical;
    forwardAgent = true;
    proxyCommand = "${lib.getExe pkgs.cloudflared} access ssh --hostname %h";
  };
in {
  home.packages = [ pkgs.cloudflared ];
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    includes = [ "unmanaged-config" ];
    matchBlocks = {
      "github.com".identityFile = "~/.ssh/self";
      mock = {
        hostname = "mock.local";
        user = "u";
        forwardAgent = true;
      };
      mock-dev = {
        hostname = "10.167.241.43";
        user = flakes.me.user;
        proxyJump = "mock";
      };
      p900 = {
        hostname = "p900.local";
        user = flakes.me.user;
      };
      ps7 = canonical-bastion "devices-bastion-ps7";
      pek = canonical-bastion "bjp-vpn1";
      "*" = {
        compression = true;
        forwardAgent = false;
        addKeysToAgent = "confirm";
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "auto";
        controlPath = "~/.ssh/master-%r@%h:%p";
        controlPersist = "5m";
      };
    };
  };
}
