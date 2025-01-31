# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: 
with lib; let
  configs = with flakes.colors; {
    ExtraWhitespace = {
      bg = "#${bright.black}";
      match = "\\s\\+$";
    };
  };
  fn = {
    highlight = cfg: removeAttrs cfg [ "match" ];
    match = cfg: cfg.match;
  };
in {
  programs.nixvim = {
    highlight = mapAttrs (_: fn.highlight) configs;
    match = mapAttrs (_: fn.match) configs;
  };
}
