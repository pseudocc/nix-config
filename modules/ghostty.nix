{ lib, pkgs, config, flakes, ... }:
with lib; let
  ghostty = flakes.ghostty.packages.${pkgs.system}.default;
  cfg = config.programs.ghostty;
  Settings = with types; let
      Primitives = either str (either bool (either int float));
      AnyPrimitives = either Primitives (listOf Primitives);
    in attrsOf AnyPrimitives;
  generate = let
    listWrap = value: if isList value then value else [value];
    toLine = key: value: let
      value' = if isBool value then boolToString value else toString value;
    in "${key} = ${value'}\n";
    toLines = key: values: concatMapStrings (toLine key) (listWrap values);
  in attrs: concatStrings (mapAttrsToList toLines attrs);
in {
  options.programs.ghostty = {
    enable = mkEnableOption "Ghostty terminal";
    settings = mkOption {
      type = Settings;
      default = {};
      example = {
        background = "282c34";
        foreground = "ffffff";
        keybind = [
          "ctrl+z=close_surface"
          "ctrl+d=new_split:right"
        ];
      };
      description = "Ghostty configuration options";
    };
    package = mkOption {
      type = types.package;
      default = ghostty;
      defaultText = literalExpression "flakes.ghostty.packages.${system}.default";
      description = "Ghostty package to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."ghostty/config".text = generate cfg.settings;
  };
}
