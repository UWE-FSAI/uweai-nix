# ROS 2 from nix-ros-overlay. The distribution is chosen here rather than by
# the OS release, so every machine runs the same ROS whatever else differs.
{ nix-ros-overlay }:
{ config, lib, pkgs, ... }:
let
  cfg = config.ads.ros;
  rosPkgs = pkgs.rosPackages.${cfg.distro};
in
{
  imports = [ nix-ros-overlay.nixosModules.default ];

  options.ads.ros = {
    enable = lib.mkEnableOption "ROS 2";

    distro = lib.mkOption {
      type = lib.types.enum [ "humble" "jazzy" "kilted" "lyrical" "rolling" ];
      default = "jazzy";
      description = "ROS 2 distribution. Change it and your build stops matching everyone else's.";
    };

    applyOverlay = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Add nix-ros-overlay to nixpkgs. Turn off if your own flake already applies it.";
    };

    desktop = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the desktop variant (RViz, rqt) rather than ros-base.";
    };

    gazebo = lib.mkOption {
      type = lib.types.bool;
      default = cfg.desktop && cfg.distro != "humble";
      defaultText = lib.literalExpression ''desktop && distro != "humble"'';
      description = "Gazebo with ros_gz. Off on Humble, where ros_gz does not evaluate in the overlay.";
    };

    buildTools = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "colcon, vcstool, CMake and a compiler for building the workspace.";
    };

    localhostOnly = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Keep ROS traffic on this machine. Stops laptops on shared university
        wifi from seeing each other's topics. The car turns this off.
      '';
    };

    domainId = lib.mkOption {
      type = lib.types.ints.between 0 232;
      default = 0;
    };

    extraPackages = lib.mkOption {
      type = lib.types.functionTo (lib.types.listOf lib.types.package);
      default = _: [ ];
      example = lib.literalExpression "p: [ p.plotjuggler-ros ]";
      description = "Extra ROS packages, given the selected distribution's package set.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Applied here rather than through services.ros2.applyOverlay, whose
    # double-application check fires on its own overlay.
    nixpkgs.overlays = lib.mkIf cfg.applyOverlay (lib.mkAfter [ nix-ros-overlay.overlays.default ]);

    services.ros2 = {
      enable = lib.mkDefault true;
      applyOverlay = false;
      distro = lib.mkDefault cfg.distro;
      domainId = lib.mkDefault cfg.domainId;
      systemPackages = p:
        [ (if cfg.desktop then p.desktop else p.ros-base) ]
        ++ lib.optionals cfg.gazebo [ p.ros-gz ]
        ++ lib.optionals cfg.buildTools [
          p.ament-cmake
          p.ament-cmake-python
          p.python-cmake-module
          p.rosidl-default-generators
        ]
        ++ cfg.extraPackages p;
    };

    environment.systemPackages = lib.optionals cfg.buildTools [
      pkgs.colcon
      rosPkgs.vcstool
      pkgs.cmake
      pkgs.gnumake
      pkgs.gcc
      pkgs.pkg-config
    ];

    environment.variables = {
      ROS_AUTOMATIC_DISCOVERY_RANGE = lib.mkDefault (if cfg.localhostOnly then "LOCALHOST" else "SUBNET");
    };

    # DDS discovery and data ports, only needed when talking off-machine.
    networking.firewall.allowedUDPPortRanges =
      lib.mkIf (!cfg.localhostOnly) [ { from = 7400; to = 7700; } ];
  };
}
