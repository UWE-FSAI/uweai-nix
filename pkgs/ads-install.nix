# Installs a build type onto a drive:  ads-install dev-x86 /dev/sdb
#
# Runs from any NixOS live ISO (`nix run github:UWE-FSAI/uweai-nix#ads-install`),
# from the ads installer stick, or from a lead's own NixOS machine with the
# drive plugged in by USB. It partitions with disko, then runs nixos-install,
# which downloads the system straight onto the target drive. The drive is
# mounted at a private directory under /run, never /mnt, so nothing the
# machine running it has mounted is touched.
# (disko-install would download it into the live system's memory first,
# which a full desktop and ROS do not fit in on most laptops.)
#
# The system always goes on an external USB drive, which then IS the boot
# drive. A computer's internal drives are never written to: the installer
# refuses any drive not connected by USB (inside a VM, the VM's own virtual
# disk is allowed), with no override. Drives that look like they hold
# Windows or macOS need --force as well.
{ writeShellApplication, util-linux, coreutils, gnugrep, nixos-install-tools, disko, flake }:
writeShellApplication {
  name = "ads-install";
  runtimeInputs = [ util-linux coreutils gnugrep nixos-install-tools disko ];
  text = ''
    types="dev-x86 dev-x86-cuda vm-x86 vm-aarch64 adsdv"
    usage() {
      echo "usage: sudo ads-install [--force] <build-type> <disk>"
      echo
      echo "build types: $types"
      echo
      echo "drives on this machine:"
      lsblk -d -e 7,11 -o NAME,SIZE,TRAN,MODEL | sed 's/^/  /'
      exit 1
    }
    stop() { echo; echo "STOPPED: $*"; echo "Nothing was changed."; exit 1; }

    force=
    if [ "''${1-}" = --force ]; then force=1; shift; fi
    [ $# -eq 2 ] || usage
    host=$1; disk=$2
    case " $types " in *" $host "*) ;; *) echo "unknown build type: $host"; usage ;; esac
    [ -b "$disk" ] || { echo "not a drive: $disk"; usage; }
    case "$(lsblk -dno TYPE "$disk")" in
      disk) ;;
      part) stop "$disk is a partition, not a whole drive. Use the name without the last number, e.g. /dev/sdb, not /dev/sdb1." ;;
      *) stop "$disk is not a drive you can install onto." ;;
    esac
    [ "$(id -u)" -eq 0 ] || { echo "run with sudo"; exit 1; }

    # Never: drives the running system is using (such as the installer stick
    # itself), or ones too small to hold the system.
    if lsblk -nlo MOUNTPOINTS "$disk" | grep -q .; then
      stop "$disk is in use by the system you're running now (probably the installer stick)."
    fi
    size=$(lsblk -dnbo SIZE "$disk")
    [ "$size" -ge 60000000000 ] || stop "$disk is too small. It needs to be at least 64 GB."

    # Never, with or without --force: a drive inside the computer.
    tran=$(lsblk -dno TRAN "$disk" | tr -d ' ')
    in_vm=
    if command -v systemd-detect-virt >/dev/null && systemd-detect-virt --vm -q; then in_vm=1; fi
    # virtio disks only exist inside VMs.
    if [ "$tran" = virtio ]; then in_vm=1; fi
    if [ -z "$in_vm" ] && [ "$tran" != usb ]; then
      stop "$disk is inside this computer (''${tran:-internal}), not a USB drive. This installer only ever writes to an external USB drive."
    fi

    # Only with --force: a USB drive that looks like it holds Windows or macOS.
    reasons=()
    if lsblk -nlo FSTYPE "$disk" | grep -qi bitlocker; then reasons+=("it has a BitLocker-encrypted partition (Windows)"); fi
    if lsblk -nlo PARTTYPE "$disk" | grep -qi de94bba4-06d1-4d40-a16a-bfd50179d6ac; then reasons+=("it has a Windows recovery partition"); fi
    if lsblk -nlo FSTYPE "$disk" | grep -qi apfs; then reasons+=("it has a macOS (APFS) partition"); fi
    if [ ''${#reasons[@]} -gt 0 ] && [ -z "$force" ]; then
      echo
      echo "$disk may have an operating system or encrypted data on it, because:"
      printf '  - %s\n' "''${reasons[@]}"
      stop "Check you picked the right drive. If you are certain, run again with --force."
    fi

    echo
    echo "About to install $host onto:"
    lsblk -o NAME,SIZE,TRAN,MODEL,FSTYPE,LABEL "$disk" | sed 's/^/  /'
    if lsblk -nlo PARTTYPE "$disk" | grep -qi c12a7328-f81f-11d2-ba4b-00a0c93ec93b; then
      echo
      echo "  Note: this drive has a boot partition, so it may have had an"
      echo "  operating system on it. That's fine if it's a drive you're reusing."
    fi
    echo
    echo "EVERYTHING on $disk will be erased."
    read -r -p "To continue, type the drive name ($disk): " ok
    [ "$ok" = "$disk" ] || stop "you typed '$ok', not '$disk'."

    mnt=$(mktemp -d /run/ads-install.XXXXXX)
    cleanup() {
      if findmnt -R "$mnt" >/dev/null 2>&1; then umount -R "$mnt" || true; fi
      rmdir "$mnt" 2>/dev/null || true
    }
    trap cleanup EXIT

    echo
    echo "Partitioning $disk..."
    disko --mode destroy,format,mount --yes-wipe-all-disks \
      --root-mountpoint "$mnt" \
      --argstr device "$disk" ${flake}/lib/disko-btrfs.nix

    # The machine gets its own small flake in /etc/nixos: the build type
    # plus local.nix, which is where its user makes changes.
    echo
    echo "Writing /etc/nixos..."
    mkdir -p "$mnt/etc/nixos"
    sed "s/@HOST@/$host/g" ${flake}/templates/installed/flake.nix > "$mnt/etc/nixos/flake.nix"
    cp ${flake}/templates/installed/local.nix "$mnt/etc/nixos/local.nix"
    chmod 644 "$mnt/etc/nixos/flake.nix" "$mnt/etc/nixos/local.nix"
    nix --extra-experimental-features 'nix-command flakes' flake lock "path:$mnt/etc/nixos"
    echo "This machine will update from: $(grep -o 'url = "[^"]*"' "$mnt/etc/nixos/flake.nix")"

    echo
    echo "Installing $host. This downloads several GB; it can take a while."
    nixos-install --root "$mnt" --no-root-password --no-channel-copy \
      --flake "path:$mnt/etc/nixos#$host" \
      --option extra-substituters https://ros.cachix.org \
      --option extra-trusted-public-keys ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=

    cleanup
    trap - EXIT
    echo
    echo "Done. Shut down (or unplug $disk), then start a computer from it."
    echo "Log in as uweai with password uwe-fsai, then change it with passwd."
  '';
  meta.description = "Install a UWE-FSAI build type onto a drive";
}
