{ pkgs, lib, ... }:
{
  hardware.enableRedistributableFirmware = true;

  hardware.graphics = lib.mkIf (!pkgs.stdenv.isAarch64) {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      (vaapiIntel.override { enableHybridCodec = true; })
      vaapiVdpau
      libvdpau-va-gl
    ];
  };
}
