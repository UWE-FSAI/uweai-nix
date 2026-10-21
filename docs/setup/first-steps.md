# First steps

You've got a working system, or a dev shell on a Mac. This gets you to
building the code. To learn ROS by making your own small project first, do
steps 1 and 2 here and then [Your first ROS project](first-ros-node.md).

## 1. Change the password

On the SSD or a VM, log in as `uweai`, open the application menu (bottom
left), search for **Konsole** and open it. Then type:

```bash
passwd
```

It asks for the current password (`uwe-fsai`), then your new one twice.
**Nothing appears as you type**; that's normal. Then run this, which stops
the terminal reminding you:

```bash
mkdir -p ~/.config/ads && touch ~/.config/ads/password-changed
```

<details>
<summary>▶ How do I use the terminal (Konsole)?</summary>

Click in the window and type, or paste, a command, then press **Enter**.
To paste in Konsole, use **Ctrl + Shift + V**, or right-click → Paste. The
**Up arrow** brings back your last command. A command has finished when you
see a line ending in `$` again.

</details>

## 2. Get online and up to date

Connect to Wi-Fi from the network icon at the bottom right.

For **eduroam** (university Wi-Fi), click **eduroam** → **Connect**. A
settings window opens: on its **Wi-Fi Security** tab, set these, then click
**OK**:

| Setting | Value |
|---|---|
| Security | WPA/WPA2 Enterprise |
| Authentication | Protected EAP (PEAP) |
| CA certificate | leave empty |
| Inner authentication | MSCHAPv2 |
| Username | your UWE username followed by `@uwe.ac.uk`, like `an2-other@uwe.ac.uk` |
| Password | your UWE password |

<details>
<summary>▶ The window looks different, or it won't connect</summary>

Do it from Konsole instead, with the same commands as the installer. Put
your UWE username in place of `an2-other`:

```bash
nmcli connection delete eduroam
nmcli connection add type wifi con-name eduroam ssid eduroam wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 802-1x.identity an2-other@uwe.ac.uk
nmcli --ask connection up eduroam
```

The first line removes any half-finished eduroam setup (it's fine if it
says there isn't one). The last asks for your UWE password; nothing appears
as you type.

</details>

Then fetch the latest society configuration whenever a lead says there's an
update:

```bash
ads-update
```

It keeps any changes you've made in `local.nix` (next step).

(On a Mac dev shell there's no machine to update. Your department's shell
comes from the workspace, which a lead moves forward; `git pull` in
`~/ads-ws` gets it.)

## 3. Make it yours (optional)

Everything the society sets up is a default you can change. On the SSD or a
VM, your changes go in one file, `/etc/nixos/local.nix`. Society updates
never overwrite it.

```bash
sudo nano /etc/nixos/local.nix
```

It has examples to start from: remove the `#` at the start of a line to use
it. Save with **Ctrl + O**, Enter, and exit with **Ctrl + X**. Then apply
your change:

```bash
ads-apply
```

If something goes wrong, restart and pick the previous entry in the start-up
menu, which is your system as it was before the change.

The editor (`nano` here, `nvim` on the car), the terminal setup, the desktop
and more can all be changed this way: see
[Changing the defaults](customising.md).

<details>
<summary>▶ What's in /etc/nixos?</summary>

- `flake.nix` says which build this machine is (for example `vm-x86`) and
  adds `local.nix` on top. You shouldn't need to edit it.
- `local.nix` is yours. Anything you set here wins over the society's
  defaults, from extra programs to a different desktop.
- `flake.lock` records exactly which version of the society's configuration
  you're on. `ads-update` moves it forward.

| Command | What it does |
|---|---|
| `ads-apply` | apply your changes to `local.nix` |
| `ads-update` | get the society's latest configuration, keeping your changes |
| `ads-version` | show which version you're on |

</details>

## 4. Connect to GitHub

The code is on GitHub. You need a free GitHub account, and a *key* so your
computer can prove it's you. Create one:

```bash
ssh-keygen -t ed25519 -C "your-email@example.com"   # press Enter to accept the defaults
cat ~/.ssh/id_ed25519.pub
```

Copy the whole line it prints (it starts `ssh-ed25519`). On
[github.com](https://github.com), click your picture (top right) →
**Settings** → **SSH and GPG keys** → **New SSH key**, paste it into *Key*,
give it a title like "uweai SSD", and click **Add SSH key**.

<details>
<summary>▶ What's an SSH key?</summary>

A pair of matching files: a private one that stays on your computer, and a
public one (the line you copied) that you give to GitHub. Together they let
GitHub recognise your computer without a password. Never share the private
one (`id_ed25519`, without `.pub`).

</details>

## 5. Get the code

```bash
git clone git@github.com:UWE-FSAI/ads-ws.git ~/ads-ws
cd ~/ads-ws
```

## 6. Enter your department's shell

Always build inside your department's shell. It has the exact ROS and
libraries everyone else builds against. The workspace has its own flake,
pinned to this configuration, so run it from the workspace:

```bash
cd ~/ads-ws && nix develop .#perception --accept-flake-config
```

Departments: `integration` (Integration), `perception` (Perception), `slam`
(SLAM, including path planning and route optimisation) and
`vehicle-development` (Vehicle Development: hardware and control systems).
The simulators are not part of `ads-ws`; they live in their own workspace,
`~/sim-ws`, with the `simulation` shell.

On an Intel Mac there are no dev shells: do this inside the VM.

## 7. Build and run

On Linux (the SSD, a VM, or NixOS), build your department's packages, for
example:

```bash
colcon build --symlink-install --packages-up-to cone_detector
source install/setup.bash
ros2 pkg list | grep cone
```

Use the package names from your department's folder under `src/`. Not every
package in the workspace builds yet, so build yours rather than the whole
tree.

**New to ROS?** [Your first ROS project](first-ros-node.md) walks you through
making a package, writing two nodes that talk to each other, and running
them, before you add your own package to the team's code.

On a Mac shell there's no ROS, so run your department's Python directly, for
example scripts and training code. To run ROS nodes, use the VM.

## Getting help

Ask in the society chat, and say which guide you followed and the last
command you ran.
