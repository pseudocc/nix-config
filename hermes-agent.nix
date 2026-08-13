# vim: et:ts=2:sw=2
{ lib, pkgs, flakes, ... }: {
  imports = [
    flakes.hermes-agent.nixosModules.default
  ];

  services.hermes-agent = {
    enable = true;
    settings.model = {
      default = "gpt-5.6-sol";
      provider = "copilot";
    };
    settings.providers.orcarouter = {
      base_url = "https://api.orcarouter.ai/v1";
      key_env = "ORCAROUTER_API_KEY";
    };
    environmentFiles = [
      "/var/lib/hermes/env"
    ];
    addToSystemPackages = true;
  };
}
