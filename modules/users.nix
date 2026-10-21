# The developer login, `uweai` by default. Its password is printed in this
# repository, so it is only ever good for the first console login: change it
# with `passwd`. SSH never accepts passwords (see remote-admin.nix).
#
# The car's own software does not run as this user; see vehicle.nix.
{ config, lib, ... }:
let
  cfg = config.ads.user;
in
{
  options.ads.user = {
    enable = lib.mkEnableOption "the default UWE-FSAI user account";

    name = lib.mkOption {
      type = lib.types.str;
      default = "uweai";
      description = "Login name of the default account.";
    };

    description = lib.mkOption {
      type = lib.types.str;
      default = "UWE-AI developer";
    };

    initialPassword = lib.mkOption {
      type = lib.types.str;
      default = "uwe-fsai";
      description = ''
        Password set when the account is first created. Not a secret: it is
        in a public repository. Changing it later with `passwd` sticks,
        because users are mutable.
      '';
    };

    groups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "wheel" "networkmanager" "video" "audio" "dialout" "plugdev" ];
      description = ''
        The account's groups. Assign your own list to replace them, or use
        `extraGroups` to add to them.
      '';
    };

    extraGroups = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Groups on top of `groups`.";
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys allowed to log in as this user.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.mutableUsers = lib.mkDefault true;

    users.users.${cfg.name} = {
      isNormalUser = true;
      description = lib.mkDefault cfg.description;
      initialPassword = lib.mkDefault cfg.initialPassword;
      extraGroups = cfg.groups ++ cfg.extraGroups;
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };
    users.groups.plugdev = { };

    # No root password; administration is sudo or SSH as the user.
    users.users.root.hashedPassword = lib.mkDefault "!";

    programs.bash.interactiveShellInit = ''
      if [ "$USER" = ${lib.escapeShellArg cfg.name} ] && [ ! -e "$HOME/.config/ads/password-changed" ]; then
        echo "Reminder: the default password is public. Run 'passwd', then"
        echo "  mkdir -p ~/.config/ads && touch ~/.config/ads/password-changed"
        echo "to stop this message."
      fi
    '';
  };
}
