# vim: et:ts=2:sw=2
{ lib, pkgs, config, flakes, ... }:
with lib; let
  system = pkgs.system;
  cfg = config.programs.ghostty;
  configType = with types; let
      primitiveType = either str (either bool int);
      multipleType = either primitiveType (listOf primitiveType);
      entryType = attrsOf multipleType;
    in entryType;
  toConfig = let
    listWrap = value: if isList value then value else [value];
    toLine = key: value: let
      value' = if isBool value then boolToString value else toString value;
    in "${key} = ${value'}\n";
    toLines = key: values: concatMapStrings (toLine key) (listWrap values);
  in attrs: concatStrings (mapAttrsToList toLines attrs);
in {
  options.programs.ghostty = {
    enable = mkEnableOption "Ghostty terminal";
    config = mkOption {
      type = configType;
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
      default = flakes.ghostty.packages.${system}.default;
      defaultText = literalExpression "flakes.ghostty.packages.${system}.default";
      description = "Ghostty package to install";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."ghostty/config".text = toConfig cfg.config;
  };
}
