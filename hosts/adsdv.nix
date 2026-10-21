# ADSDV: the in-car PC. Its 2.5" SATA SSD is written on a bench machine, put
# in the car, and must start the mission selector from power-on with no
# input and no network.
{ lib, ... }:
{
  imports = [ ../profiles/vehicle.nix ];
  networking.hostName = lib.mkDefault "adsdv";
  ads.portable.enable = lib.mkDefault true;
  ads.portable.disk.imageSize = lib.mkDefault "64G";
  ads.cuda.enable = lib.mkDefault true;
  ads.cuda.toolkit = lib.mkDefault false;
}
