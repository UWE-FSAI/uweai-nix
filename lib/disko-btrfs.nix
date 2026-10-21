# One drive: an EFI partition and a btrfs volume with subvolumes.
#
# /var/lib/ads is its own subvolume so recorded bags can be snapshotted,
# excluded or wiped without touching the system, and zstd compression roughly
# halves what bags and the Nix store take up.
#
# `device` is set by ads-install to the external drive it was given. The
# default deliberately names no real drive, so nothing can ever partition a
# computer's own disk by accident. Mounts are by partition label, so the result
# boots from whichever port the drive is plugged into.
{ device ? "/dev/disk/by-id/set-by-ads-install", imageSize ? "32G", espSize ? "1G", ... }:
{
  disko.devices.disk.main = {
    type = "disk";
    inherit device imageSize;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = espSize;
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };
        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [ "-f" ];
            subvolumes =
              let opts = [ "compress=zstd" "noatime" ];
              in {
                "/@root" = { mountpoint = "/"; mountOptions = opts; };
                "/@nix" = { mountpoint = "/nix"; mountOptions = opts; };
                "/@home" = { mountpoint = "/home"; mountOptions = opts; };
                "/@ads" = { mountpoint = "/var/lib/ads"; mountOptions = opts; };
              };
          };
        };
      };
    };
  };
}
