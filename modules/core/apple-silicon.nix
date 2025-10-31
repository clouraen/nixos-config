{ lib, options, pkgs, ... }:
let
  hasAsahiModule = lib.hasAttrByPath [ "hardware" "asahi" ] options;
  asahiPackages =
    lib.optionals (pkgs ? asahi-fwextract) [ pkgs.asahi-fwextract ]
    ++ lib.optionals (pkgs ? asahi-scripts) [ pkgs.asahi-scripts ];
in
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

  hardware =
    {
      opengl = {
        enable = true;
        driSupport = true;
        driSupport32Bit = lib.mkDefault false;
      };
    }
    // lib.optionalAttrs hasAsahiModule {
      asahi =
        {
          enable = true;
          withRust = true;
          setupAsahiSound = true;
        }
        // lib.optionalAttrs (pkgs ? asahi-fwextract) {
          gpuFirmwarePackage = lib.mkDefault pkgs.asahi-fwextract;
        };
    };

  environment.systemPackages = lib.mkAfter asahiPackages;
}
