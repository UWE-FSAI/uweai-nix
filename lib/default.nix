{ self, nixpkgs, nix-ros-overlay, disko }:
let
  inherit (nixpkgs) lib;

  modules = {
    base = import ../modules/base.nix { inherit self disko; };
    users = ../modules/users.nix;
    ros = import ../modules/ros.nix { inherit nix-ros-overlay; };
    desktop = ../modules/desktop.nix;
    cuda = ../modules/cuda.nix;
    can = ../modules/can.nix;
    remote-admin = ../modules/remote-admin.nix;
    portable = ../modules/portable.nix;
    vehicle = ../modules/vehicle.nix;
    shell = ../modules/shell.nix;
  };

  # Every build type: the platform it's for and its host module.
  hosts = {
    dev-x86 = { system = "x86_64-linux"; module = ../hosts/dev-x86.nix; };
    dev-x86-cuda = { system = "x86_64-linux"; module = ../hosts/dev-x86-cuda.nix; };
    vm-x86 = { system = "x86_64-linux"; module = ../hosts/vm-x86.nix; };
    vm-aarch64 = { system = "aarch64-linux"; module = ../hosts/vm-aarch64.nix; };
    adsdv = { system = "x86_64-linux"; module = ../hosts/adsdv.nix; };
    adsdv-sim = { system = "x86_64-linux"; module = ../hosts/adsdv-sim.nix; };
    installer = { system = "x86_64-linux"; module = ../hosts/installer.nix; };
  };

  # Builds a machine from this flake's modules plus your own. Members'
  # flakes can call this instead of nixpkgs.lib.nixosSystem.
  mkSystem = { system, modules ? [ ], specialArgs ? { } }:
    lib.nixosSystem {
      inherit system;
      specialArgs = { uweaiNix = self; } // specialArgs;
      modules = [
        self.nixosModules.default
        disko.nixosModules.disko
        {
          nixpkgs.hostPlatform = lib.mkDefault system;
          system.configurationRevision = lib.mkDefault (self.rev or self.dirtyRev or null);
        }
      ] ++ modules;
    };

  # A build type, with your own modules on top.
  mkHost = name: { modules ? [ ] }:
    mkSystem {
      inherit (hosts.${name}) system;
      modules = [ hosts.${name}.module ] ++ modules;
    };
in
{
  inherit modules hosts mkSystem mkHost;

  allModules = { imports = builtins.attrValues modules; };

  # What an installed machine's /etc/nixos/flake.nix calls: its build type,
  # with local.nix on top, and ads-update / ads-apply pointed at /etc/nixos
  # so local changes survive society updates.
  mkLocal = { host, modules ? [ ], flakeDir ? "/etc/nixos" }:
    mkHost host {
      modules = [ { ads.base.updateFlake = lib.mkDefault "path:${flakeDir}#${host}"; } ] ++ modules;
    };

  # The ads-install script, for a given package set.
  installer = pkgs: pkgs.callPackage ../pkgs/ads-install.nix {
    disko = disko.packages.${pkgs.stdenv.hostPlatform.system}.disko;
    flake = self;
  };

  # The shared btrfs disk layout, for hosts that want it.
  diskoBtrfs = import ./disko-btrfs.nix;
}
