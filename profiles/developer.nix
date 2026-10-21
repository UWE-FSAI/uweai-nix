# Quickstart for a member's machine: everything switched on at default
# priority. Turn any piece off, or change it, with a plain assignment.
{ lib, ... }:
{
  ads.base.enable = lib.mkDefault true;
  ads.user.enable = lib.mkDefault true;
  ads.ros.enable = lib.mkDefault true;
  ads.desktop.enable = lib.mkDefault true;
  ads.can.enable = lib.mkDefault true;
  ads.remoteAdmin.enable = lib.mkDefault true;
  ads.shell.enable = lib.mkDefault true;
  # So scripts/check.sh can evaluate the ARM builds from any x86 machine.
  ads.base.emulateAarch64 = lib.mkDefault true;

  # For `nixos-rebuild build-vm` on any developer build: Plasma and RViz need
  # more than the 1 GB default. Set your own in local.nix, e.g.
  #   virtualisation.vmVariant.virtualisation.memorySize = 8192;
  virtualisation.vmVariant.virtualisation = {
    memorySize = lib.mkDefault 4096;
    cores = lib.mkDefault 4;
  };
}
