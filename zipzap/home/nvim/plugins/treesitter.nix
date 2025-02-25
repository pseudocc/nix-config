# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: let
  treesitter-pxu-grammar = let
    package = pkgs.tree-sitter.buildGrammar {
      language = "pxu";
      version = "0.1.1";
      src = pkgs.fetchFromGitHub {
        owner = "pseudocc";
        repo = "tree-sitter-pxu";
        rev = "8d07d20c21f0243c7169a5e00b9eafeb13681e7b";
        sha256 = "yvFvEEas4DevqomzDqHMfX/RI0bP0nEtWKUI+ZhnnDw=";
      };
      meta.homepage = "https://github.com/pseudocc/tree-sitter-pxu";
    };
  in package.overrideAttrs {
    fixupPhase = ''
      mkdir -p $out/queries/pxu
      mv $out/queries/*.scm $out/queries/pxu/
    '';
  };
in {
  programs.nixvim.plugins.treesitter = {
    enable = true;

    settings = {
      indent.enable = false;
      highlight.enable = true;
    };

    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      c       cpp     make    cmake   llvm
      bash    lua     python  vim     vimdoc
      css     scss    html    svelte
      typescript      javascript      jsdoc
      haskell rust    zig     go      groovy
      proto   json    yaml    toml    xml     jsonc
      udev    objdump awk     jq     hyprlang tmux

      treesitter-pxu-grammar
    ];

    languageRegister = {
      pxu = "pxu";
    };

    luaConfig.post = ''
      local Treesitter = {};
      Treesitter.config = require('nvim-treesitter.parsers').get_parser_configs()
      Treesitter.config.pxu = {
        install_info = {
          url = '${treesitter-pxu-grammar}',
          files = { 'src/parser.c', 'src/scanner.c' },
          branch = 'main',
        },
        filetype = 'pxu',
      }
    '';
  };

  home.packages = [ pkgs.tree-sitter ];
}
