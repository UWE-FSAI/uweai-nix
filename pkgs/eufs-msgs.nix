# eufs_msgs, the Edinburgh University Formula Student messages. Not in
# nix-ros-overlay or the ROS index, so it is packaged here.
#
# Temporary: the workspace still imports it (planners, mission_handler,
# sensor_to_odometry) while the team migrates away from the EUFS simulator.
# Remove it once that migration is done.
#
# Call with a distribution's package set:
#   pkgs.rosPackages.jazzy.callPackage ./eufs-msgs.nix { }
{ lib, buildRosPackage, fetchFromGitLab, ament-cmake, ament-lint-common
, rosidl-default-generators, rosidl-default-runtime, std-msgs, geometry-msgs
, sensor-msgs }:
buildRosPackage {
  pname = "ros-eufs-msgs";
  version = "2.0.0-unstable-2025-10-16";

  src = fetchFromGitLab {
    owner = "eufs";
    repo = "eufs_msgs";
    rev = "9e918686c9e9292c613f321e6fd85e3a5d87cd87";
    hash = "sha256-y89a4T5ta7epGOoT+ckw7M6lfrmJhKI4G3poxJM3OgI=";
  };

  buildType = "ament_cmake";
  buildInputs = [ ament-cmake rosidl-default-generators ];
  checkInputs = [ ament-lint-common ];
  propagatedBuildInputs = [ rosidl-default-runtime std-msgs geometry-msgs sensor-msgs ];
  nativeBuildInputs = [ ament-cmake rosidl-default-generators ];

  meta = {
    description = "ROS messages and services used by EUFS";
    homepage = "https://gitlab.com/eufs/eufs_msgs";
    license = with lib.licenses; [ mit ];
  };
}
