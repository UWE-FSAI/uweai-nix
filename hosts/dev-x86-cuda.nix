# As dev-x86, plus the NVIDIA driver and CUDA. Only for NVIDIA machines.
{ lib, ... }:
{
  imports = [ ./dev-x86.nix ];
  networking.hostName = lib.mkOverride 999 "dev-x86-cuda";
  ads.cuda.enable = lib.mkDefault true;
  ads.portable.disk.imageSize = lib.mkDefault "48G";
}
