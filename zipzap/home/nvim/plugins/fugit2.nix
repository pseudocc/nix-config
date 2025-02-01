# vim: et:ts=2:sw=2
{ lib, pkgs, pkgs-unstable, flakes, ... }:
with pkgs; let
  fugit2 = with vimPlugins; pkgs-unstable.vimPlugins.fugit2-nvim.overrideAttrs {
    version = "pseudocc";
    src = fetchFromGitHub {
      owner = "pseudocc";
      repo = "fugit2.nvim";
      rev = "0168416187fcfda314b5c31eff957f44acfa0807";
      sha256 = "JcGYXIGANkJ7fB5AJOiwy3XvGmSyx/Ipme9d5p8/aLQ=";
    };
    checkInputs = [ nvim-web-devicons ];
    dependencies = [
      nui-nvim
      plenary-nvim
      gpgme
      libgit2
    ];
  };

  libPath = pkg: file: "${lib.getLib pkg}/lib/${file}";
in {
  programs.nixvim.plugins.fugit2 = {
    enable = true;
    package = fugit2;
    settings = {
      gpgme_path = libPath gpgme "libgpgme.so";
      libgit2_path = libPath libgit2 "libgit2.so";
    };
    luaConfig.post = ''
      map('n', ',g', wrapVimCmd('Fugit2'), 'Fugit2: main')
    '';
  };
}
