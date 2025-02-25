# vim: et:ts=2:sw=2
{
  description = "pseudoc";

  inputs = {
    # Nix
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    # Ghostty Terminal (Customized)
    ghostty.url = "github:pseudocc/ghostty";

    # Theme
    catppuccin.url = "github:catppuccin/nix";

    # Firmware
    intel-npu.url = "github:pseudocc/linux-npu-driver";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    zig,
    nixpkgs-unstable,
    home-manager,
    ...
  } @ inputs:
  let
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

        nixvim.lua = code: { __raw = code; };
      };

      packages.neovim-terminal = ./packages/neovim-terminal.nix;

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
      };
    };
  in {
    nixosConfigurations = let
      pkgs-unstable = import nixpkgs-unstable { inherit system; };
    in {
      zipzap = nixpkgs.lib.nixosSystem rec {
        overlays = [
          (final: prev: rec {
            unstable = pkgs-unstable;
            nix = unstable.nix;
          })
        ];
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
