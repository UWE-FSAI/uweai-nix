# A VM on an x86 Windows, Linux or Intel Mac machine.
{ lib, ... }:
{
  imports = [ ./vm.nix ];
  networking.hostName = lib.mkDefault "vm-x86";
}
