# vim: et:ts=2:sw=2
{
  description = "pseudoc";

  inputs = {
    # Nix
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Ghostty Terminal (Customized)
    ghostty.url = "github:pseudocc/ghostty";

    # Theme
    catppuccin.url = "github:catppuccin/nix";

    # Firmware
    intel-npu.url = "github:pseudocc/linux-npu-driver";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  } @ inputs:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    flakes = inputs // rec {
      me = rec {
        nick = "pseudoc";
        user = nick;
        name = "Atlas Yu";
        email = "${nick}@163.com";
        signingKey = "BEA76B7637CEBC8A";
        description = "Real Vim enthusiast & Rust hater.";
      };

      lib = with builtins; {
        embedFile = { path, sha256 }: toString (fetchurl {
          url = "file://${toString path}";
          sha256 = sha256;
        });
      };

      packages.neovim-terminal = pkgs.callPackage ./packages/neovim-terminal.nix {
        cursor = {
          foreground = colors.cursor.primary;
          background = colors.surface;
          inactive = {
            foreground = colors.bright.black;
            background = colors.surface;
          };
        };
      };

      homeManagerModules.ghostty = { lib, pkgs, config, flakes, ... }:
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
      };

      colors = rec {
        base = "13131e";
        surface = "272120";
        overlay = black;
        highlight = "ffafa2";
        text = "ddbfb9";

        background = base;
        foreground = text;
        cursor = {
          primary = highlight;
          secondary = bright.red;
        };
    
        black = "413736";
        red = "db475f";
        green = "6ead47";
        yellow = "c68c2e";
        blue = "5a9bec";
        magenta = "c36ee7";
        cyan = "33acac";
        white = "cfc4c2";
    
        bright = {
          black = "756764";
          red = "ed6677";
          green = "7fc453";
          yellow = "dfa13e";
          blue = "7cb1f5";
          magenta = "d18fef";
          cyan = "3dc4c4";
          white = "f8f6f6";
        };
      };
    };
  in {
    nixosConfigurations = {
      zipzap = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit flakes; };
        system = "x86_64-linux";
        modules = [
          ./nixos.nix
          ./zipzap/nixos.nix
        ];
      };
    };
  };
}
