# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  imports = [
    flakes.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;
    settings.model = {
      default = "openai/gpt-5.6-sol";
    };
    environmentFiles = [
      "/var/lib/hermes/env"
    ];
    addToSystemPackages = true;
  };
}
