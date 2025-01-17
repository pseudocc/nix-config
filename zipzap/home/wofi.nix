# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  programs.wofi = {
    enable = true;
    settings = {
      show="drun";
      prompt="An idiot admires complexity, a genius admires simplicity.";
      width=640;
      height=400;
      always_parse_args=true;
      show_all=false;
      print_command=true;
      insensitive=true;
      key_expand="Tab";
    };
    style = with flakes.colors; ''
      @define-color base #${base};
      @define-color surface #${surface};
      @define-color input #${bright.black};
      @define-color text #${text};
      @define-color primary #${red};
      @define-color secondary #${bright.yellow};
    '' + builtins.readFile ./wofi.css;
  };
}
