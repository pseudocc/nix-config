rec {
  base = "13131e";
  surface = "2f3243";
  overlay = black;
  highlight = "ffafa2";
  highlight-low = "dd7878";
  text = "ddbfb9";

  background = base;
  foreground = text;
  cursor = {
    primary = highlight;
    secondary = highlight-low;
  };

  black = "413736";
  red = "db475f";
  green = "71aa53";
  yellow = "dfa13e";
  blue = "89b4fa";
  magenta = "c6a0f6";
  cyan = "81c8be";
  white = "cfc4c2";

  bright = {
    black = "6e768c";
    red = "ed6677";
    green = "9fc7a5";
    yellow = "f9e2af";
    blue = "89dceb";
    magenta = "f5bde6";
    cyan = "94e2d5";
    white = "f8f6f6";
  };
}
