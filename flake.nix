{
  description = "NixOS configuration for UWE-FSAI developer machines and vehicle compute";

  inputs = {
    # nixpkgs follows nix-ros-overlay's pin on purpose: ros.cachix.org builds
    # against exactly that revision, so following it is what makes ROS come
    # down as binaries instead of compiling for hours.
    nix-ros-overlay.url = "github:lopsided98/nix-ros-overlay/develop";
    nixpkgs.follows = "nix-ros-overlay/nixpkgs";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  nixConfig = {
    extra-substituters = [ "https://ros.cachix.org" ];
    extra-trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };

  outputs = { self, nixpkgs, nix-ros-overlay, disko, ... }:
    let
      inherit (nixpkgs) lib;
      ads = import ./lib { inherit self nixpkgs nix-ros-overlay disko; };

      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      shellSystems = linuxSystems ++ [ "aarch64-darwin" ];
    in
    {
      lib = ads;

      # Every module is inert until enabled, so importing any of them on your
      # own machine changes nothing by itself. `default` brings in all of
      # them; the profiles then switch on a sensible set.
      nixosModules = ads.modules // {
        default = ads.allModules;
        developer = ./profiles/developer.nix;
        vehicle = ./profiles/vehicle.nix;
      };

      # Build any of these as-is:
      #   sudo nixos-rebuild switch --flake github:UWE-FSAI/uweai-nix#dev-x86
      # Every build type in lib/default.nix (`hosts`): dev-x86, dev-x86-cuda,
      # vm-x86, vm-aarch64, adsdv (the car), adsdv-sim and the installer.
      nixosConfigurations = lib.mapAttrs (name: _: ads.mkHost name { }) ads.hosts;

      packages = lib.genAttrs linuxSystems (system:
        let
          cfgs = lib.filterAttrs (_: c: c.pkgs.stdenv.hostPlatform.system == system) self.nixosConfigurations;
          image = name: cfgs.${name}.config.system.build.diskoImages;
        in
        {
          # `sudo nix run github:UWE-FSAI/uweai-nix#ads-install -- dev-x86 /dev/sdX`
          ads-install = ads.installer nixpkgs.legacyPackages.${system};
        }
        // lib.optionalAttrs (system == "x86_64-linux") {
          # Ready-to-write drive images: `nix build .#usb-dev-x86`, then dd the
          # result onto a USB drive. Building these needs KVM.
          usb-dev-x86 = image "dev-x86";
          usb-dev-x86-cuda = image "dev-x86-cuda";
          vm-x86-disk = image "vm-x86";
          adsdv-image = image "adsdv";
          # A boot stick that installs any of the above onto another drive,
          # with no KVM needed to build it.
          installer-iso = cfgs.installer.config.system.build.isoImage;
          adsdv-sim-vm = cfgs.adsdv-sim.config.system.build.vm;
        }
        // lib.optionalAttrs (system == "aarch64-linux") {
          vm-aarch64-disk = image "vm-aarch64";
        });

      devShells = lib.genAttrs shellSystems (system:
        import ./shells { inherit system nixpkgs nix-ros-overlay; });

      templates = {
        member = {
          path = ./templates/member;
          description = "Your own machine, built on the UWE-FSAI configuration";
        };
        # Written to /etc/nixos by ads-install; @HOST@ is the build type.
        installed = {
          path = ./templates/installed;
          description = "An installed machine's own flake: a build type plus local.nix";
        };
        default = self.templates.member;
      };

      formatter = lib.genAttrs shellSystems (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
