# For a system that lives on a drive rather than in a machine: a USB stick
# booted on any laptop, or the car's SSD written on a bench machine.
#
# GRUB goes to the removable-media path (EFI/BOOT/BOOTX64.EFI), which every
# UEFI firmware boots without an NVRAM entry, the initrd carries drivers for
# common hardware rather than one machine's, and the root filesystem grows to
# fill the drive on first boot.
{ config, lib, pkgs, ... }:
let
  cfg = config.ads.portable;
  x86 = pkgs.stdenv.hostPlatform.isx86;
in
{
  options.ads.portable = {
    enable = lib.mkEnableOption "booting from a drive moved between machines";

    disk = {
      layout = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Use the shared btrfs layout (lib/disko-btrfs.nix) for the drive.";
      };
      imageSize = lib.mkOption {
        type = lib.types.str;
        default = "32G";
        description = "Size of the built drive image. It grows to fill the real drive on first boot.";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (lib.mkIf cfg.disk.layout (import ../lib/disko-btrfs.nix { inherit (cfg.disk) imageSize; }))
    {
      # disko's image builder hands vmTools a module tree as its kernel, which
      # current nixpkgs can no longer find the kernel image in. Naming the
      # image explicitly fixes `nix build .#usb-*`; remove once disko does.
      nixpkgs.overlays = [
        (final: prev: {
          vmTools = prev.vmTools.override {
            kernelImage = prev.linux.target;
          };
        })
      ];

      boot.loader.systemd-boot.enable = lib.mkDefault false;
      boot.loader.grub = {
        enable = lib.mkDefault true;
        efiSupport = lib.mkDefault true;
        efiInstallAsRemovable = lib.mkDefault true;
        device = lib.mkDefault "nodev";
        configurationLimit = lib.mkDefault 10;
      };
      boot.loader.efi.canTouchEfiVariables = lib.mkDefault false;
      boot.loader.efi.efiSysMountPoint = lib.mkDefault "/boot";

      boot.initrd.availableKernelModules = [
        "xhci_pci" "ehci_pci" "ahci" "nvme" "usbhid" "usb_storage" "uas" "sd_mod" "sdhci_pci"
        "thunderbolt" "virtio_pci" "virtio_blk" "virtio_scsi"
      ];
      boot.kernelModules = lib.optionals x86 [ "kvm-intel" "kvm-amd" ];

      hardware.enableRedistributableFirmware = lib.mkDefault true;
      hardware.cpu.intel.updateMicrocode = lib.mkDefault x86;
      hardware.cpu.amd.updateMicrocode = lib.mkDefault x86;

      # First boot: grow the partition, then the filesystem, to fill the drive.
      boot.growPartition = lib.mkDefault true;
      systemd.services.ads-grow-root = {
        description = "Grow the root btrfs filesystem to fill its partition";
        wantedBy = [ "multi-user.target" ];
        after = [ "local-fs.target" ];
        serviceConfig.Type = "oneshot";
        unitConfig.ConditionPathExists = "!/var/lib/ads-grow-root.done";
        script = ''
          if [ "$(${pkgs.util-linux}/bin/findmnt -no FSTYPE /)" = btrfs ]; then
            ${pkgs.btrfs-progs}/bin/btrfs filesystem resize max /
          fi
          touch /var/lib/ads-grow-root.done
        '';
      };
    }
  ]);
}
