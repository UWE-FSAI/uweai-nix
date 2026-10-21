# Development shells, one per department plus a general one:
#
#   nix develop github:UWE-FSAI/uweai-nix#perception
#
# On Linux each carries the same pinned ROS 2 as every machine, plus what that
# department's packages import. On macOS, ROS through Nix is only partly
# supported upstream, so department shells there carry the department's
# non-ROS tools (Python libraries, linters), and `#ros` is offered as an
# experiment. For full ROS on a Mac, use the vm-aarch64 build.
{ system, nixpkgs, nix-ros-overlay }:
let
  pkgs = import nixpkgs {
    inherit system;
    overlays = [ nix-ros-overlay.overlays.default ];
    config.allowUnfree = true;
  };
  inherit (pkgs) lib;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  py = pkgs.python3Packages;

  tools = with pkgs; [ git cmake gnumake pkg-config ruff clang-tools nixfmt ];

  # What every department's ROS packages build against.
  rosCommon = p: with p; [
    ros-base
    ament-cmake
    ament-cmake-core
    ament-cmake-python
    python-cmake-module
    rosidl-default-generators
    launch-ros
    ament-copyright
    ament-flake8
    ament-pep257
    ament-lint-auto
    ament-lint-common
    tf2-ros
    tf2-geometry-msgs
    visualization-msgs
    nav-msgs
  ];
  # Temporary, until the move away from the EUFS simulator is done: the
  # workspace still imports eufs_msgs, which nothing else packages.
  eufsMsgs = p: p.callPackage ../pkgs/eufs-msgs.nix { };

  pythonCommon = [ py.numpy py.scipy py.matplotlib py.pyyaml py.pytest py.ipython ];

  # Taken from what each department's package.xml files and Python imports
  # use in the UWE-FSAI workspace.
  departments = {
    integration = {
      ros = p: with p; [ xacro robot-state-publisher joint-state-publisher rviz2 rqt-gui pluginlib (eufsMsgs p) ];
      python = [ py.python-can ];
      linuxPython = [ py.cantools ];
      packages = [ pkgs.can-utils ];
    };
    perception = {
      ros = p: with p; [ cv-bridge image-transport vision-msgs ];
      python = [ py.torch py.torchvision py.ultralytics py.opencv4 py.pandas py.pillow py.tqdm py.pycocotools ];
      packages = [ ];
    };
    # SLAM, plus path planning and route optimisation (path_planner,
    # global_planner, acceleration_planner).
    slam = {
      # GTSAM's C++ library. Its Python bindings (graphslam_node imports
      # `gtsam`) are not packaged in nixpkgs or the overlay yet.
      ros = p: with p; [ rviz2 gtsam robot-state-publisher ackermann-msgs (eufsMsgs p) ];
      python = [ py.pandas ];
      packages = [ pkgs.eigen ];
    };
    # Vehicle hardware and control systems: motion_controller, autonomous_demo
    # and static_inspection_a, which talk to the VCU over /AI2VCU and /VCU2AI.
    vehicle-development = {
      ros = p: with p; [ rviz2 robot-state-publisher ackermann-msgs (eufsMsgs p) ];
      python = [ py.simple-pid py.python-can ];
      linuxPython = [ py.cantools ];
      packages = [ pkgs.can-utils ];
    };
    simulation = {
      ros = p: with p; [
        ros-gz xacro robot-state-publisher joint-state-publisher rviz2 rqt-gui
        ackermann-msgs image-transport image-geometry std-srvs python-qt-binding
      ];
      python = [ py.pandas py.pillow ];
      packages = [ pkgs.yaml-cpp ];
    };
  };

  rosShell = { name, distro ? "jazzy", dept ? { ros = _: [ ]; python = [ ]; packages = [ ]; } }:
    let p = pkgs.rosPackages.${distro};
    in pkgs.mkShell {
      name = "ads-${name}";
      packages = tools ++ dept.packages ++ [
        pkgs.colcon
        p.vcstool
        (p.buildEnv { paths = rosCommon p ++ dept.ros p ++ pythonCommon ++ dept.python ++ dept.linuxPython or [ ]; })
      ];
      shellHook = ''
        export ROS_AUTOMATIC_DISCOVERY_RANGE=''${ROS_AUTOMATIC_DISCOVERY_RANGE:-LOCALHOST}
        echo "uweai-nix ${name} shell: ROS 2 ${distro}. Build with: colcon build --symlink-install"
      '';
    };

  pythonShell = { name, dept ? { python = [ ]; packages = [ ]; } }:
    pkgs.mkShell {
      name = "ads-${name}";
      packages = tools ++ dept.packages ++ [ (pkgs.python3.withPackages (_: pythonCommon ++ dept.python)) ];
      shellHook = ''
        echo "uweai-nix ${name} shell (no ROS on this system; use the vm-aarch64 build for ROS)."
      '';
    };

  # Packages that do not build on macOS are dropped there rather than
  # breaking the whole shell. `linuxPython` lists ones whose dependencies
  # fail on macOS even though they themselves claim to support it.
  forDarwin = dept: dept // {
    python = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) dept.python;
    packages = lib.filter (lib.meta.availableOn pkgs.stdenv.hostPlatform) dept.packages;
  };
in
if isDarwin then
  lib.mapAttrs (name: dept: pythonShell { inherit name; dept = forDarwin dept; }) departments // {
    default = pythonShell { name = "tools"; };
    tools = pythonShell { name = "tools"; };
    ros = rosShell { name = "ros"; };
  }
else
  lib.mapAttrs (name: dept: rosShell { inherit name dept; }) departments // {
    default = rosShell { name = "default"; };
    humble = rosShell { name = "humble"; distro = "humble"; };
    lyrical = rosShell { name = "lyrical"; distro = "lyrical"; };
    tools = pythonShell { name = "tools"; };
  }
