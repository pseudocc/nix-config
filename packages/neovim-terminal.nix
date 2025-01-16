# vim: et:ts=2:sw=2
{ lib, pkgs, stdenv, cursor, ... }:
let
  envsubst = lib.getExe pkgs.envsubst;
  neovim = lib.getExe pkgs.neovim;
in
stdenv.mkDerivation rec {
  name = "neovim-terminal";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = ./${name};
  };

  nativeBuildInputs = [ pkgs.envsubst ];
  buildInputs = [ pkgs.neovim ];

  installPhase = ''
    mkdir -p $out/bin

    NIX_STORE=$out \
    SHELL=${pkgs.runtimeShell} \
    NVIM=${neovim} \
      ${envsubst} < ${name}/wrapper.sh > $out/bin/nvim-term

    chmod +x $out/bin/nvim-term

    CURSOR_FG=${cursor.foreground} \
    CURSOR_BG=${cursor.background} \
    INACTIVE_CURSOR_FG=${cursor.inactive.foreground} \
    INACTIVE_CURSOR_BG=${cursor.inactive.background} \
      ${envsubst} < ${name}/.vimrc > $out/.vimrc
  '';
}
