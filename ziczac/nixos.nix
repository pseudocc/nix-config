# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }:
let
  voiceBindings = { press, release ? press, actions, device ? null, ignorePressMods ? false }:
    let
      deviceOptions = lib.optionalAttrs (device != null) { device.list = [ device ]; };
      pressOptions = deviceOptions // lib.optionalAttrs ignorePressMods { ignore_mods = true; };
    in [
      {
        _args = [ press (lib.generators.mkLuaInline "${actions}.press") ]
          ++ lib.optionals (device != null || ignorePressMods) [ pressOptions ];
      }
      {
        _args = [
          release
          (lib.generators.mkLuaInline "${actions}.release")
          (deviceOptions // { release = true; transparent = true; ignore_mods = true; })
        ];
      }
    ];
in {
  imports = [
    ../zsetup.nix
    ./hardware.nix

    flakes.nixos-hardware.nixosModules.lenovo-thinkpad-x1-yoga
    flakes.home-manager.nixosModules.home-manager
    flakes.catppuccin.nixosModules.catppuccin
    flakes.vinput.nixosModules.default
  ];

  home-manager = {
    extraSpecialArgs = { inherit flakes; };
    users.${flakes.me.user} = {
      imports = [ ./home/default.nix ];
      wayland.windowManager.hyprland.settings = {
        vinputMakeHold._var = lib.generators.mkLuaInline ''function(record, write)
          local held = false
          return {
            press = function()
              held = true
              hl.exec_cmd(record)
            end,
            release = function()
              if held then
                held = false
                hl.exec_cmd(write)
              end
            end,
          }
        end'';
        vinputRaw._var = lib.generators.mkLuaInline
          ''vinputMakeHold("vinput record", "vinput write")'';
        vinputRules._var = lib.generators.mkLuaInline
          ''vinputMakeHold("vinput record-rules", "vinput write-rules")'';

        bind = voiceBindings {
          press = "SUPER + SHIFT + F23";
          release = "F23";
          actions = "vinputRaw";
        }
        ++ voiceBindings {
          # KEY_RIGHTALT (evdev 100) maps to Alt_R in this US XKB layout.
          # Ignore modifiers on press as Alt_R is itself a modifier.
          press = "Alt_R";
          actions = "vinputRules";
          device = "at-translated-set-2-keyboard";
          ignorePressMods = true;
        };
      };
    };
  };

  networking.hostName = "ziczac";
  time.timeZone = "Asia/Shanghai";

  programs.vinput = {
    enable = true;
    package = flakes.vinput.packages.${pkgs.stdenv.hostPlatform.system}.default;
    language = "en";
  };
  users.users.${flakes.me.user}.extraGroups = [ "ydotool" ];

  services.vinput-asr = {
    enable = true;
    device = "NPU";
    language = "en";
  };
  systemd.services.vinput-asr.serviceConfig.SupplementaryGroups = [ "render" ];

  security.pki.certificateFiles = [
    ./rootCA.pem
    ./mDNS.pem
  ];

  zsetup = {
    pipewire = true;
    locations = "all";
    desktop = pkgs.gtk4.dev;
    session = "${pkgs.hyprland}/share/wayland-sessions";
  };
}
