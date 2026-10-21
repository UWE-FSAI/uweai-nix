# Shared by the VM build types: guest tools for QEMU-based hypervisors (UTM,
# virt-manager, GNOME Boxes). Same Plasma desktop as every other graphical
# build, so a VM looks and behaves like a member's laptop.
{ lib, ... }:
{
  imports = [ ../profiles/developer.nix ];
  ads.portable.enable = lib.mkDefault true;
  ads.portable.disk.imageSize = lib.mkDefault "48G";
  services.qemuGuest.enable = lib.mkDefault true;
  services.spice-vdagentd.enable = lib.mkDefault true;

}
