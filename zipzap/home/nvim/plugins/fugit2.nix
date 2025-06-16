# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }:
let
  libPath = pkg: file: "${lib.getLib pkg}/lib/${file}";
in {
  programs.nixvim.plugins.fugit2 = {
    enable = true;
    settings = {
      width = "80%";
      height = "80%";
      min_width = 55;
      max_width = 90;
      gpgme_path = libPath pkgs.gpgme "libgpgme.so";
      libgit2_path = libPath pkgs.libgit2 "libgit2.so";
    };
    luaConfig.post = ''
      _M.map('n', ',g', _M.wrapVimCmd('Fugit2'), 'Fugit2: main')
    '';
  };
}
