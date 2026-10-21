# Setting up your machine

Pick the guide that matches the computer you have. Each one goes from a
computer that works today to a working setup, and they all end up with the
same tools and versions as everyone else.

| You have | Your options | Guide |
|---|---|---|
| A Mac | Your department's dev shell (Apple Silicon), or a full Linux VM | [I have a Mac](mac.md) |
| A Windows or Linux PC or laptop | An external USB SSD you start from, or a VM | [I have a PC or laptop](pc.md) |
| NixOS already | Add the society config to yours | [I already use NixOS](nixos.md) |

All three finish with [First steps](first-steps.md): your password, your
department's shell, and building the code. Then
[Your first ROS project](first-ros-node.md) takes you from an empty folder to
two ROS nodes talking to each other, assuming you've never used ROS.
[Changing the defaults](customising.md) covers the editor, the terminal
setup and anything else you want different.

> **Your computer's own drive is never touched.** On a PC, the society's
> system goes onto an external USB SSD, and that SSD is the drive you start
> from. On a Mac, nothing is erased or replaced. The installer refuses to
> write to any drive inside a computer.

**Quickest: have your SSD made from one that already works.** Anyone
already running the society's system (a member's SSD, a VM, or a lead's
NixOS machine) can turn your empty external SSD into a working one with one
command, `sudo ads-install dev-x86 /dev/sdX`. Ask a project lead, or see
[Making an SSD from an existing one](pc.md#making-an-ssd-from-an-existing-one).
You then skip straight to [First steps](first-steps.md).

**Starting from nothing?** The guides fall back to the NixOS minimal
installer: a text-only system you start from a USB stick or load into a VM.
There's no desktop while installing, so you'll type a handful of commands,
and the guides give each one. Keep the guide open on your phone while you
install. Once installed, you get the full KDE Plasma desktop. For an SSD,
follow [I have a PC or laptop](pc.md) steps 1 to 7, then
[First steps](first-steps.md).

**Not sure which?** On a PC, the external SSD gives you the full system at
full speed and leaves your computer exactly as it was when it's unplugged.
On an Apple Silicon Mac, start with the dev shell and add the VM only if you
need to run ROS; on an Intel Mac, use the VM. New to Linux? Every guide
assumes that, and explains each step.

## What you'll be logging in as

Every graphical build has the KDE Plasma desktop and the user `uweai`, with
password `uwe-fsai`. That password is printed here, in public, so change it
the first time you log in.
