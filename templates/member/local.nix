# Your machine, your choices. Anything set here beats the society defaults.
{ lib, pkgs, ... }:
{
  # Must match the name in flake.nix (nixosConfigurations.<name>).
  networking.hostName = "my-machine";

  # Tell `ads-update` where this flake lives.
  ads.base.updateFlake = "/etc/nixos#my-machine";

  # Already have your own user and desktop? Keep them and skip the society's:
  # ads.user.enable = false;
  # ads.desktop.enable = false;

  # More examples:
  # ads.cuda.enable = true;                # NVIDIA machines
  # ads.ros.extraPackages = p: [ p.plotjuggler-ros ];
  # ads.user.name = "yourname";
  # environment.systemPackages = [ pkgs.zed-editor ];

  # Default editor (git, sudoedit and so on); nano unless you change it:
  # ads.shell.editor = "nvim";
  # Already have your own dotfiles? Skip the society's terminal setup:
  # ads.shell.enable = false;

  # More: docs/setup/customising.md in uweai-nix
}
