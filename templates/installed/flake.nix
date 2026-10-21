{
  description = "This machine's configuration";

  # This machine runs the society's @HOST@ build, with your own changes from
  # local.nix on top. Nothing here is ever pushed anywhere.
  #
  #   sudo nano /etc/nixos/local.nix   change something
  #   ads-apply                        apply your change
  #   ads-update                       get the society's latest, keeping yours

  inputs.uweai-nix.url = "github:UWE-FSAI/uweai-nix";

  outputs = { uweai-nix, ... }: {
    nixosConfigurations.@HOST@ = uweai-nix.lib.mkLocal {
      host = "@HOST@";
      modules = [ ./local.nix ];
    };
  };
}
