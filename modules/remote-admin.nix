# SSH for fixing machines remotely. Key-only: the default password is public,
# so it must never work over the network.
{ config, lib, ... }:
let
  cfg = config.ads.remoteAdmin;
in
{
  options.ads.remoteAdmin = {
    enable = lib.mkEnableOption "key-only SSH access";

    adminKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = ''
        Project leads' SSH public keys, allowed to log in as the default
        user. Empty by default, so granting a lead access is a deliberate,
        reviewed change.
      '';
    };

    tailscale.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Join a tailnet. Off by default: someone has to own the account, and the car never has internet anyway.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = lib.mkDefault true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
      };
    };
    ads.user.authorizedKeys = cfg.adminKeys;
    services.tailscale.enable = lib.mkIf cfg.tailscale.enable (lib.mkDefault true);
  };
}
