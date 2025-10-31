{ lib, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/core
    ./../../modules/core/apple-silicon.nix
  ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "schedutil";
}
