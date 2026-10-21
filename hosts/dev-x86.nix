# A member's x86 laptop or desktop, started from an external USB SSD (the
# laptop's own drive is never touched). Hardware-independent: the same SSD
# starts on any x86 machine.
{ lib, ... }:
{
  imports = [ ../profiles/developer.nix ];
  networking.hostName = lib.mkDefault "dev-x86";
  ads.portable.enable = lib.mkDefault true;
}
