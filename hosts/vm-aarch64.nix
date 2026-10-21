# A VM on an Apple Silicon Mac (UTM), or any ARM64 host.
{ lib, ... }:
{
  imports = [ ./vm.nix ];
  networking.hostName = lib.mkDefault "vm-aarch64";
}
