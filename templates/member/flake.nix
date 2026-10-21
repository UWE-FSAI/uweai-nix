{
  description = "My UWE-FSAI machine";

  # This file lives on YOUR machine (/etc/nixos), next to your existing
  # configuration.nix, not in the society repository, so nothing of yours is
  # ever tracked or pushed there. See docs/setup/nixos.md in uweai-nix.
  #
  # Update to the newest society configuration with `ads-update`, or:
  #   sudo nix flake update uweai-nix --flake /etc/nixos
  #   sudo nixos-rebuild switch --flake /etc/nixos#my-machine

  inputs = {
    uweai-nix.url = "github:UWE-FSAI/uweai-nix";
    # Use the exact nixpkgs the society builds against, so ROS comes from
    # the binary cache. Drop this to bring your own nixpkgs.
    nixpkgs.follows = "uweai-nix/nixpkgs";
  };

  outputs = { uweai-nix, ... }: {
    nixosConfigurations.my-machine = uweai-nix.lib.mkSystem {
      system = "x86_64-linux";
      modules = [
        # The society's developer set. Delete it and enable only the parts
        # you want instead, e.g. `ads.ros.enable = true;` in local.nix.
        uweai-nix.nixosModules.developer
        # Your existing NixOS configuration, unchanged.
        ./hardware-configuration.nix
        ./configuration.nix
        # Your choices on top of the society defaults.
        ./local.nix
      ];
    };
  };
}
