# The ADSDV build as a VM on your laptop, with a virtual CAN bus in place of
# the real one:  nixos-rebuild build-vm --flake .#adsdv-sim
#
# Each setting here sits one step above the adsdv defaults it replaces
# (mkOverride 999) rather than mkForce, so a plain assignment still wins.
{ lib, ... }:
let
  mkSimDefault = lib.mkOverride 999;
in
{
  imports = [ ./adsdv.nix ];
  networking.hostName = mkSimDefault "adsdv-sim";
  ads.cuda.enable = mkSimDefault false;
  ads.can = {
    virtual.enable = mkSimDefault true;
    hardware.enable = mkSimDefault false;
  };
  ads.vehicle.autostart.launchArgs = lib.mkDefault [ "can_interface:=vcan0" ];
  virtualisation.vmVariant.virtualisation = {
    memorySize = lib.mkDefault 4096;
    cores = lib.mkDefault 2;
  };
}
