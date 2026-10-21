# uweai-nix

NixOS configuration for every machine UWE-FSAI runs: members' laptops (x86,
x86 with NVIDIA, Apple Silicon), the in-car PC and, later, the Jetson. One
pinned set of versions, so the code builds the same everywhere.

**New member?** Start with [docs/setup](docs/setup/README.md): guides for a
Mac, a PC or laptop, and existing NixOS users. The code itself is in
[UWE-FSAI/ads-ws](https://github.com/UWE-FSAI/ads-ws), cloned to `~/ads-ws`.

**Project lead?** [docs/RUNBOOK.md](docs/RUNBOOK.md) covers updates, the car
and handover.

## Three ways to use it

**1. As-is.** Each build type is a complete system. Developer builds go onto
an external USB SSD, which is then the drive the computer starts from; a
computer's internal drive is never written to, and `ads-install` refuses
internal drives outright.

Most new SSDs are made from a machine that already has the system. Every
society build (SSDs, VMs, the car, the installer stick) includes
`ads-install`, so one working machine is enough to set everyone else up
again. Plug the new SSD in by USB and run:

```bash
sudo ads-install dev-x86 /dev/sdX     # no arguments: lists build types and drives
```

On any other NixOS machine, or the NixOS minimal installer, run the same
thing straight from GitHub:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' run --accept-flake-config \
  github:UWE-FSAI/uweai-nix#ads-install -- dev-x86 /dev/sdX
```

If you're starting with nothing at all, the NixOS minimal installer on a USB
stick (or in a VM) is the fallback; the [setup guides](docs/setup/README.md)
walk through both routes step by step.

Whichever machine runs it, the new drive follows `github:UWE-FSAI/uweai-nix`
and is installed from its latest revision, fetched at install time; only the
disk layout and the `/etc/nixos` templates come from the machine running it.

Each installed machine gets its own small flake in `/etc/nixos`: its build
type plus a `local.nix` where its user changes anything they like
([templates/installed](templates/installed)). `ads-apply` applies local
changes; `ads-update` pulls the society's latest underneath them.

| Build type | For | Login |
|---|---|---|
| `dev-x86` | any x86 laptop or desktop, started from an external USB SSD | `uweai` |
| `dev-x86-cuda` | the same, with the NVIDIA driver and CUDA | `uweai` |
| `vm-x86` | a VM on an x86 Windows, Linux or Intel Mac machine | `uweai` |
| `vm-aarch64` | a VM on an Apple Silicon Mac (UTM) | `uweai` |
| `adsdv` | the car (Autonomous Driving System, Designated Vehicle); starts the mission selector at boot with no input | leads only, over SSH |
| `adsdv-sim` | the car's build as a VM on your laptop, with a virtual CAN bus | `uweai` |

On the car the stack runs as `adsdv`, a service account nobody logs in as.
The default editor is `nano` on developer builds and `nvim` on the car.

**2. As an input, with your own changes.** `nix flake init -t
github:UWE-FSAI/uweai-nix` gives you a small flake that pulls this one in
([guide](docs/setup/nixos.md)). Settings here are defaults (`lib.mkDefault`
or similar), so a plain assignment in your `local.nix` wins, and your config
never leaves your machine. The only exceptions are SSH's key-only login and
the car's `adsdv` service ([details](docs/setup/customising.md)).

**3. Just the parts you want.** Each module is inert until enabled, so an
existing config can take only, say, ROS:

```nix
imports = [ uweai-nix.nixosModules.ros ];
ads.ros.enable = true;
```

Modules: `base`, `users`, `ros`, `desktop`, `cuda`, `can`, `remote-admin`,
`portable`, `vehicle`, `shell`, and `default` (all of them). The `developer`
and `vehicle` profiles switch on a sensible set; they only set options, so
import `default` alongside them.

## Department shells (Linux, and macOS on Apple Silicon)

For working on your own machine without installing NixOS. Members working on
the code should open them through the workspace, which pins this flake:
`cd ~/ads-ws && nix develop .#perception`. Straight from here:

```bash
nix develop github:UWE-FSAI/uweai-nix#perception --accept-flake-config
```

| Shell | Linux | macOS |
|---|---|---|
| `integration` | ROS 2 Jazzy, xacro, RViz, rqt, pluginlib, python-can, cantools, can-utils | python-can, can-utils |
| `perception` | ROS 2 Jazzy, cv_bridge, PyTorch, Ultralytics, OpenCV | PyTorch, Ultralytics, OpenCV |
| `slam` | SLAM, path planning and route optimisation: ROS 2 Jazzy, GTSAM (C++), RViz, ackermann_msgs, Eigen, pandas | pandas, Eigen |
| `vehicle-development` | vehicle hardware and control systems: ROS 2 Jazzy, RViz, ackermann_msgs, simple-pid, python-can, cantools, can-utils | simple-pid, python-can, can-utils |
| `simulation` | ROS 2 Jazzy, Gazebo (ros_gz), xacro, RViz, rqt; for the simulators in `~/sim-ws`, not an `ads-ws` department | pandas, Pillow |
| `default` | ROS 2 Jazzy, colcon, vcstool | the same as `tools` |
| `humble` | ROS 2 Humble, for Quanser's QCar 2 nodes | |
| `lyrical` | ROS 2 Lyrical, not yet verified | |
| `tools` | Python and linters, no ROS | the same |
| `ros` | | ROS 2 Jazzy, experimental |

All of them include NumPy, SciPy, Matplotlib, pytest, ruff and the ament
linters' Python side, so the code style checks match CI. ROS through Nix is
only partly supported on macOS, so Mac shells leave it out; `#ros` is there
to try, and the `vm-aarch64` build gives full ROS on a Mac. Intel Macs have
no dev shells: use the `vm-x86` build.

GTSAM's Python bindings, which `graphslam_node` imports, aren't packaged yet.

`eufs_msgs` ([pkgs/eufs-msgs.nix](pkgs/eufs-msgs.nix), from
gitlab.com/eufs/eufs_msgs) is in the `integration`, `slam` and
`vehicle-development` shells on Linux. It's temporary, until the move away
from the EUFS simulator is done.

## Checking a change

```bash
./scripts/check.sh
```

evaluates every machine, image and shell, ARM ones included. On x86 that
needs ARM emulation (`ads.base.emulateAarch64`), which developer builds
switch on. CI runs the same on every push.

## Layout

```
flake.nix           inputs (nixpkgs follows nix-ros-overlay, for the ROS binary cache)
lib/                mkSystem, the shared btrfs disk layout
modules/            the ads.* options
profiles/           developer and vehicle quickstarts
hosts/              the machine types above, and the installer stick
shells/             dev shells
pkgs/               ads-install, and eufs_msgs (temporary)
templates/member/   the flake an existing NixOS user keeps in /etc/nixos
templates/installed the /etc/nixos flake and local.nix ads-install writes
docs/               setup guides and the leads' runbook
scripts/check.sh    evaluate everything
```
