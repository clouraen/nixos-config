{ lib, pkgs, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "xhci_hcd"
      "usbhid"
      "usb_storage"
      "uas"
      "nvme"
      "sd_mod"
    ];
    initrd.kernelModules = [ "uas" ];
    kernelModules = [ "apple_mca" ];
  };

  hardware = {
    asahi = {
      enable = true;
      withRust = true;
      setupAsahiSound = true;
      gpuFirmwarePackage = lib.mkDefault pkgs.asahi-fwextract;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = lib.mkDefault false;
    };
  };

  environment.systemPackages = lib.mkAfter (with pkgs; [
    asahi-fwextract
    asahi-scripts
  ]);
}
