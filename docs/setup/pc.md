# I have a PC or laptop

> **Your computer's own drive is never touched.**
>
> The society's system is installed onto an **external USB SSD**, and that
> SSD *is* the drive your computer starts from when you want to work on the
> car's software. Nothing is installed on, written to, or erased from the
> drive inside your computer, at any step. Unplug the SSD and your computer
> starts and works exactly as it does today.
>
> The installer enforces this: it refuses to write to any drive inside the
> computer, even if you tell it to.

**Someone already has the system running?** That's the usual way: they can
make your SSD for you in one command, with no installer stick. See
[Making an SSD from an existing one](#making-an-ssd-from-an-existing-one).
The rest of this guide is the fallback, for starting from nothing with the
NixOS minimal installer.

There are two ways to do this:

- **An external SSD you start from** (recommended). Full speed, full
  graphics, and everything the society uses. This guide is mostly about this.
- **A virtual machine (VM)**: the same system running in a window on your
  current computer. Quicker to try, but slower, and graphics-heavy tools
  (Gazebo, CUDA) are limited. See [Option 2](#option-2-a-virtual-machine).

This guide assumes you've never used Linux. Anything marked with ▶ opens
when you click it, for extra help if you need it.

<details>
<summary>▶ New to all this? A few words explained</summary>

- **Linux / NixOS:** an operating system, like Windows or macOS. NixOS is the
  version of Linux the society uses, set up so that everyone's is identical.
- **Drive:** where a computer keeps its files. Your computer has one inside
  it (the *internal* drive). An *external* drive plugs into a USB port.
- **SSD:** a fast kind of drive. An *external SSD* is a small box that plugs
  in by USB.
- **USB stick:** a small, cheap drive, often used to carry files around.
- **Booting / starting up from a drive:** when a computer turns on, it loads
  its operating system from a drive. Normally that's the internal one; you
  can tell it to use a USB drive instead, just for that start-up.
- **Terminal** or **command line:** where you type commands instead of
  clicking. The installer is nothing but this: a screen of text with no
  mouse or windows. You'll type a few commands; this guide gives you every
  one, exactly.

</details>

## What you need

| | |
|---|---|
| **A working computer** | The PC or laptop you'll use, running Windows or any Linux. It needs a USB port, and works best with 8 GB of memory or more. |
| **An external USB SSD** | 128 GB or larger. This becomes your NixOS drive. It can be brand new, or formatted as NTFS, exFAT or anything else: **everything on it will be erased**. |
| **A USB stick** | 2 GB or larger, for the installer. Also erased. You only need it once, so it can be borrowed. |
| **This guide on another screen** | Your phone is fine. While installing, your computer shows only text, so you'll read the commands from here. |
| **Internet** | Wi-Fi is fine. |
| **About an hour** | Most of it is waiting for downloads. |

<details>
<summary>▶ Which SSD should I get?</summary>

Any external SSD from a known brand (Samsung T7, Crucial X9, SanDisk
Extreme, Kingston XS1000 and similar) at 256 GB or more is a good choice.
Plug it into a USB 3 port: these are often blue inside, or marked "SS" or
with a lightning bolt. A USB *stick* can be used as the NixOS drive too, but
it will be much slower.

</details>

<details>
<summary>▶ What does "formatted" or "NTFS" mean?</summary>

Formatting sets a drive up to hold files in a particular way; NTFS and exFAT
are two of those ways. It doesn't matter how your SSD is formatted now,
because the installer sets it up from scratch. It just means anything
already on it will be gone.

</details>

## Step 1: Copy anything you want off the SSD and the stick

Both get erased. If they're new, there's nothing to do.

## Step 2: Find your BitLocker key (Windows only)

Skip this step if your computer doesn't run Windows.

In Step 4 you'll change a start-up setting called Secure Boot. On many
Windows computers, that makes Windows ask, once, for a **BitLocker recovery
key** next time it starts. Without the key you could be locked out of
Windows, so get it **now**.

1. Click Start and type **device encryption**. If *Device encryption
   settings* appears, open it and see whether it's **On**. If nothing
   appears, type **manage bitlocker** instead and see whether drive C: says
   **BitLocker on**.
2. If neither is on, there's no key to find. Skip to *Turn off Fast
   Startup* below.
3. If it's on, get the key: on your phone or another computer, go to
   [aka.ms/myrecoverykey](https://aka.ms/myrecoverykey) and sign in with the
   Microsoft account you use on this computer. Find the entry whose
   *Device name* matches this computer.
4. **Write the key down or photograph it** (it's 48 digits, in groups of 6).
   Keep it somewhere that isn't this computer.

<details>
<summary>▶ What is BitLocker? And I can't find my key</summary>

BitLocker scrambles everything on your Windows drive so nobody can read it
if the computer is stolen. The recovery key unscrambles it if Windows ever
isn't sure it's really you, for example after a start-up setting changes.

If the key isn't in your Microsoft account, open **Manage BitLocker** (or
**Device encryption**) and choose **Back up your recovery key**, then
*Print* or *Save to a file* on another drive. If the computer belongs to
your university or employer, their IT team has the key.

**If you can't get the key, stop here** and ask a project lead. Use
[Option 2](#option-2-a-virtual-machine) in the meantime: it doesn't need any
start-up settings changed.

</details>

**Turn off Fast Startup.** Windows' Fast Startup can stop the computer
noticing USB drives at start-up. Open Control Panel → **Power Options** →
**Choose what the power buttons do** → **Change settings that are currently
unavailable**, untick **Turn on fast startup**, and click **Save changes**.
This doesn't affect anything else.

## Step 3: Make the installer stick

You can do this on any computer: Windows, macOS or Linux.

1. Go to [nixos.org/download](https://nixos.org/download). Under *NixOS: the
   Linux distribution*, download the **Minimal ISO image** for **64-bit
   Intel/AMD**. It's a single file of about 1.5 GB ending in `.iso`. Not the
   *Graphical* one: these guides are written for the minimal one.
2. Install [balenaEtcher](https://etcher.balena.io) (free) and open it.
3. Plug in the **USB stick**. Not the SSD yet: keeping the SSD unplugged
   means you can't pick it by mistake.
4. In Etcher: **Flash from file** → choose the `.iso` → **Select target** →
   tick **your USB stick**. Check the name and size match the stick. →
   **Flash!** It may ask for your computer's password.
5. When it says *Flash Complete*, close Etcher and unplug the stick.

<details>
<summary>▶ Windows says "You need to format the disk" or "Scan and fix"</summary>

Click **Cancel**. Windows can't read the installer stick and is offering to
erase it. The stick is fine.

</details>

<details>
<summary>▶ What's an ISO file?</summary>

A copy of a whole disc or drive packed into one file. Etcher unpacks it onto
the stick, which turns the stick into something your computer can start
from.

</details>

## Step 4: Turn off Secure Boot

Secure Boot is a start-up setting that only lets the computer start
operating systems signed by Microsoft. The society's system isn't signed
that way, so Secure Boot has to be **off** for the SSD to start. This is a
setting on the computer itself, not in Windows, and it doesn't change any
files.

1. **Open the computer's settings screen** (called the *BIOS*, *UEFI* or
   *setup*). The easiest way, on Windows: Settings → System → **Recovery** →
   next to *Advanced startup*, **Restart now** → **Troubleshoot** →
   **Advanced options** → **UEFI Firmware Settings** → **Restart**.
   Otherwise, turn the computer on and immediately tap the setup key
   repeatedly: usually **F2** or **Del**, sometimes **F1**, **F10** or
   **Esc**.
2. Find **Secure Boot**. It's usually on a tab called **Boot**, **Security**
   or **Authentication**. Use the arrow keys and Enter, or the mouse if it
   works.
3. Set it to **Disabled**.
4. **Save and exit**, usually with **F10**, then confirm. The computer
   restarts.
5. If Windows starts and asks for a **BitLocker recovery key**, type in the
   key from Step 2. It only asks once.

Change nothing else in this screen. In particular, leave anything called
**UEFI** on, and **CSM** or **Legacy** off.

<details>
<summary>▶ The Secure Boot option is greyed out or missing</summary>

Every manufacturer arranges this screen differently. The common fixes:

- **Acer, and some HP and Lenovo:** set a *Supervisor* or *Administrator
  password* first (Security tab); Secure Boot can then be changed. You can
  clear that password again afterwards.
- **ASUS:** Boot → Secure Boot → set **OS Type** to **Other OS**.
- **MSI and Gigabyte desktops:** look for *Secure Boot Mode* or *Windows
  8/10 Features* and choose **Other OS**, or **Custom**, then Disabled.
- **Dell:** Boot Configuration (or *Secure Boot*) → turn off **Enable Secure
  Boot**.
- **HP:** Advanced → Secure Boot Configuration → choose **Legacy Support
  Disable and Secure Boot Disable**.
- Still stuck? Search the web for your exact model plus "disable secure
  boot", or ask a project lead.

</details>

<details>
<summary>▶ Will this break Windows? Can I turn it back on?</summary>

Windows works normally with Secure Boot off. The one thing that can need it
on is the anti-cheat in some online games (for example Valorant). If you
play those, turn Secure Boot back on when you want to play, and off again
before starting from the SSD. Same screen, same setting; Windows may ask
for the BitLocker key again.

</details>

## Step 5: Start the computer from the installer stick

1. Shut the computer down. Plug in the **installer stick only**: keep the
   SSD unplugged for now.
2. Turn the computer on and immediately tap the **boot menu key**:

   | Make | Key |
   |---|---|
   | Dell, Lenovo, Acer, Toshiba | **F12** |
   | HP | **F9** (or Esc, then F9) |
   | ASUS | **Esc** (laptops) or **F8** (desktops) |
   | MSI | **F11** |
   | Gigabyte | **F12** |
   | Microsoft Surface | hold **Volume Down** while pressing power |

   On Windows you can also use Settings → System → Recovery → **Advanced
   startup** → **Restart now** → **Use a device**.
3. A list of drives appears. Choose the USB stick: it may say *USB*, *UEFI:*
   followed by the stick's name, or just its brand.
4. A NixOS menu appears. Press **Enter** on the first option.
5. Text scrolls past for a minute, then stops at a line ending like this:
   ```
   [nixos@nixos:~]$
   ```
   That's the *prompt*: NixOS is running from the stick and waiting for you
   to type a command. The installer is text only, with no desktop or mouse.
   Nothing has been installed anywhere.

<details>
<summary>▶ The text is too small to read</summary>

Type this and press Enter:
```bash
setfont ter-v32n
```

</details>

<details>
<summary>▶ It just starts Windows, or the stick isn't in the list</summary>

- Try another USB port, directly on the computer rather than through a hub
  or dock.
- Check Secure Boot really is off (Step 4) and Fast Startup is off (Step 2).
- Make the stick again (Step 3); occasionally a flash fails.

</details>

## Step 6: Install onto the SSD

Now you'll get online, find the SSD, check it really is the SSD, and install
onto it. Keep this guide open on your phone or another computer: you'll type
each command yourself, as there's no copy and paste in the installer.

<details>
<summary>▶ How do I type commands?</summary>

- Type the command exactly as shown, including spaces and punctuation, then
  press **Enter**.
- Made a mistake before pressing Enter? Use **Backspace**, or the **Left**
  and **Right** arrow keys to move along the line.
- The **Up arrow** brings back your last command, to fix and run again.
- A command has finished when the `[nixos@nixos:~]$` prompt comes back.
- **Ctrl + C** stops a command that's still running.

</details>

1. **Set your keyboard.** The installer starts with a US keyboard layout. On
   a UK keyboard, type this first, so that keys like `@`, `"` and `#` type
   what's printed on them:
   ```bash
   sudo loadkeys uk
   ```
   For other layouts, use `de`, `fr`, `es` and so on in place of `uk`.
2. **Get online.** Pick whichever you have:
   - **A network cable, or your phone's USB tethering:** this works by
     itself. Skip to the check below.
   - **eduroam (university Wi-Fi):** type these two commands. In the first,
     put your UWE username in place of `an2-other`, keeping `@uwe.ac.uk`:
     ```bash
     nmcli connection add type wifi con-name eduroam ssid eduroam wifi-sec.key-mgmt wpa-eap 802-1x.eap peap 802-1x.phase2-auth mschapv2 802-1x.identity an2-other@uwe.ac.uk
     nmcli --ask connection up eduroam
     ```
     The second asks for your UWE password. **Nothing appears as you
     type**; that's normal. Press Enter, and it should say *Connection
     successfully activated*.
   - **Home Wi-Fi or a phone hotspot:** type `nmtui` and press Enter. Use the
     arrow keys and Enter: choose **Activate a connection**, pick your
     network, type its password, then choose **Back** and **Quit**.

   Then check you're online:
   ```bash
   ping -c 3 nixos.org
   ```
   Three lines containing *bytes from* means you're online. *Temporary
   failure in name resolution* or *Network is unreachable* means you're not
   yet: wait a few seconds and try again.

   <details>
   <summary>▶ eduroam didn't connect</summary>

   - **A typo in the first command:** type
     `nmcli connection delete eduroam`, then both commands again.
   - **"Secrets were required, but not provided":** the password was wrong
     or took too long. Run `nmcli --ask connection up eduroam` again.
   - **Still nothing:** check your username works by logging in to a UWE
     website with it. Out of range of eduroam, or still stuck, use a phone
     hotspot for the install instead.

   </details>

   <details>
   <summary>▶ What do the eduroam settings mean?</summary>

   They're UWE's eduroam settings, from
   [UWE IT's own guide](https://www.uwe.ac.uk/-/media/uwe/documents/study/its-wifi-on-android-2020.pdf),
   written out for NetworkManager, the program that manages the network:

   | In the command | UWE's setting |
   |---|---|
   | `ssid eduroam` | network name: eduroam |
   | `wifi-sec.key-mgmt wpa-eap` | security: WPA Enterprise (a username and password, not one shared password) |
   | `802-1x.eap peap` | EAP method: PEAP |
   | `802-1x.phase2-auth mschapv2` | phase 2 authentication: MSCHAPV2 |
   | `802-1x.identity an2-other@uwe.ac.uk` | identity: your UWE username followed by `@uwe.ac.uk` |

   UWE's guide says not to validate a CA certificate, so there isn't one.

   </details>

3. **Look at the drives *before* plugging in the SSD.** With the SSD still
   unplugged, type:
   ```bash
   lsblk -d -o NAME,SIZE,TRAN,MODEL
   ```
   This lists the drives the computer can see. You'll see your computer's
   own drive (often called `nvme0n1` or `sda`) and the installer stick.
4. **Plug in the SSD**, wait five seconds, and run the same command again
   (press the **Up arrow** key, then **Enter**). **One new line has
   appeared: that is your SSD.** Check it says `usb` and that the size
   matches your SSD. Remember its NAME, for example `sdb`.

   <details>
   <summary>▶ Example: before and after</summary>

   Before plugging in the SSD:
   ```
   NAME     SIZE TRAN   MODEL
   sda       29G usb    SanDisk Ultra       ← the installer stick
   nvme0n1  477G nvme   SAMSUNG MZVL2512    ← the computer's own drive
   ```
   After:
   ```
   NAME     SIZE TRAN   MODEL
   sda       29G usb    SanDisk Ultra
   sdb      932G usb    Samsung PSSD T7     ← new: this is the SSD
   nvme0n1  477G nvme   SAMSUNG MZVL2512
   ```
   Here the SSD is `sdb`. Yours may differ; always use the new line.

   </details>

5. **Install.** Type the command below, but replace `sdb` at the end with
   your SSD's name. If the computer has an **NVIDIA** graphics card, change
   `dev-x86` to `dev-x86-cuda`.
   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' run --accept-flake-config github:UWE-FSAI/uweai-nix#ads-install -- dev-x86 /dev/sdb
   ```
   It's one long line. Keep typing when you reach the edge of the screen,
   and it carries on onto the next line by itself. Press Enter only at the
   end.

   <details>
   <summary>▶ Typing it in pieces</summary>

   It's easier to type accurately a piece at a time. There's one space
   between each piece:

   | Piece | What it means |
   |---|---|
   | `sudo nix` | run Nix with permission to set up drives |
   | `--extra-experimental-features 'nix-command flakes'` | switch on the Nix features the society's setup uses (two dashes at the start, straight quote marks) |
   | `run --accept-flake-config` | run a program, using the download sources the society's setup lists |
   | `github:UWE-FSAI/uweai-nix#ads-install` | the program: the society's installer, fetched from GitHub. No spaces |
   | `--` | the end of Nix's options. Everything after this goes to the installer |
   | `dev-x86` | what to install: a developer machine |
   | `/dev/sdb` | where to install it: your SSD |

   On a UK keyboard after `sudo loadkeys uk`, `#` is the key next to Enter.
   Without it, `#` is **Shift + 3**.

   </details>

6. **Check and confirm.** It shows the drive it's about to use. Check the
   size and name are your SSD's, then type the drive name (for example
   `/dev/sdb`) and press Enter. If anything looks wrong, just press Enter
   without typing: nothing will be changed.
7. **Wait.** It sets up the SSD, then downloads the system straight onto it.
   This is several GB and usually takes 15 to 45 minutes. When it prints
   **Done**, type `poweroff` and press Enter.

<details>
<summary>▶ Does my computer have an NVIDIA graphics card?</summary>

On Windows: right-click the Start button → **Device Manager** → expand
**Display adapters**. If anything there says **NVIDIA**, use
`dev-x86-cuda`. If it only says Intel or AMD, use `dev-x86`.

</details>

<details>
<summary>▶ It printed "STOPPED"</summary>

Nothing was changed; the installer stopped before touching any drive. Read
the line after *STOPPED*:

- *inside this computer, not a USB drive*: you typed the name of an
  internal drive. Go back to steps 3 and 4 to find the SSD.
- *in use by the system you're running now*: that's the installer stick.
- *too small*: the SSD needs to be at least 64 GB.
- *may have an operating system or encrypted data on it*: the drive has
  Windows, macOS or BitLocker data on it. Make sure it's the right drive
  and you've copied off what you need. If it is, add `--force` right after
  `ads-install --` in the command and run it again.

</details>

<details>
<summary>▶ "sudo" asked for a password / "command not found"</summary>

On the NixOS installer, `sudo` never asks for a password. If it does, or
says *command not found*, you're probably not in the NixOS installer: start
again from Step 5.

</details>

## Step 7: Start from the SSD

1. Unplug the installer stick. **Keep the SSD plugged in.**
2. Turn the computer on and tap the **boot menu key** again (the table in
   Step 5). Choose the **SSD** this time.
3. The first start takes a little longer. You'll see a login screen: log in
   as **`uweai`** with password **`uwe-fsai`**.

Now continue with [First steps](first-steps.md), starting by changing that
password.

### Day to day

- **To use NixOS:** plug in the SSD, turn on, boot menu key, choose the SSD.
- **To use your normal system:** just turn on without the SSD (or choose
  your normal drive from the boot menu). Nothing about it has changed.
- **Always shut NixOS down before unplugging the SSD.** Pulling it out while
  NixOS is running is like pulling the drive out of a running computer.
- **Optional:** in the settings screen from Step 4, you can put USB first in
  the *Boot order*, so the computer starts from the SSD whenever it's
  plugged in, and from its own drive when it isn't.

<details>
<summary>▶ The screen stays black after choosing the SSD</summary>

On some laptops with NVIDIA graphics, `dev-x86-cuda` doesn't show a
picture. Install again (Steps 5 and 6) with `dev-x86` instead; you can still
do everything except CUDA work. Tell a project lead your laptop's model so
it can be fixed.

</details>

## Making an SSD from an existing one

The quickest way to a new SSD, with no installer stick: on any computer
that's already running the society's system (someone's SSD, a VM, or a
lead's NixOS machine), with an internet connection.

1. Open Konsole and list the drives, then plug the new SSD in by USB and
   list them again. The new line with `usb` under TRAN is the SSD, for
   example `sdb`:

   ```bash
   lsblk -d -o NAME,SIZE,TRAN,MODEL
   ```

2. Install onto it, using its name from step 1. Use `dev-x86-cuda` in place
   of `dev-x86` if the computer it's for has an NVIDIA graphics card:

   ```bash
   sudo ads-install dev-x86 /dev/sdb
   ```

   Every society machine has `ads-install`. On a NixOS machine that isn't
   one, use the long form instead:

   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' run --accept-flake-config github:UWE-FSAI/uweai-nix#ads-install -- dev-x86 /dev/sdb
   ```

   Either way, the new SSD gets the society's latest system from GitHub,
   not a copy of the computer you run it on.

   It's the same installer as in [Step 6](#step-6-install-onto-the-ssd), with
   the same checks: it refuses any drive that isn't on USB, and the drive
   the computer is running from. It asks you to type the drive's name
   before erasing anything.

3. When it says *Done*, unplug the SSD. Whoever it's for then does
   [Step 4](#step-4-turn-off-secure-boot) (Secure Boot) and
   [Step 7](#step-7-start-from-the-ssd) on their own computer, then
   [First steps](first-steps.md).

## Option 2: a virtual machine

A virtual machine (VM) is a pretend computer running in a window. Its
"drive" is just a large file on your computer, so nothing else on your
computer is changed. You need about 70 GB of free space and 8 GB of memory
or more.

These steps use VirtualBox on Windows. On Linux, see
[Linux host](#linux-host) below.

1. Install [VirtualBox](https://www.virtualbox.org/wiki/Downloads) (free),
   and download the NixOS **Minimal ISO image, 64-bit Intel/AMD** from
   [nixos.org/download](https://nixos.org/download).
2. In VirtualBox, click **New**:
   - Name: `uweai`. ISO Image: the NixOS `.iso`. Type: **Linux**, Version:
     **Other Linux (64-bit)**. Tick **Skip Unattended Installation**.
   - Hardware: **4096 MB** memory (8192 if your computer has 16 GB or
     more), **4** processors, and tick **Enable EFI**. This one matters:
     without it the VM won't start after installing.
   - Hard Disk: **64 GB**. Click **Finish**.
3. Select the VM → **Settings** → **Display** → set Video Memory to
   **128 MB** → OK.
4. Click **Start**. Press Enter on the first NixOS menu option, and wait for
   the `[nixos@nixos:~]$` prompt. Click inside the VM window to type into
   it; press the **right Ctrl** key to get your mouse back.
5. On a UK keyboard, first type `sudo loadkeys uk` (see
   [Step 6](#step-6-install-onto-the-ssd), which also explains typing
   commands). The VM's internet works by itself. Then type this, as one
   line:
   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' run --accept-flake-config github:UWE-FSAI/uweai-nix#ads-install -- vm-x86 /dev/sda
   ```
   Inside the VM, `/dev/sda` is the VM's own pretend drive, not your
   computer's. Type `/dev/sda` to confirm, then wait for **Done**, and type
   `poweroff`.
6. In **Settings** → **Storage**, click the NixOS `.iso` in the list → the
   small disc icon on the right → **Remove Disk from Virtual Drive**.
7. **Start** the VM again and log in as **`uweai`** with password
   **`uwe-fsai`**. Continue with [First steps](first-steps.md).

### Linux host

Use **virt-manager** or GNOME Boxes with the same ISO, memory, processors
and disk size. In virt-manager, tick **Customize configuration before
install** and set **Firmware** to **UEFI** on the Overview page. The VM's
drive is `/dev/vda` rather than `/dev/sda`.

If you already have Nix, you can try a throwaway VM without installing
anything:

```bash
nixos-rebuild build-vm --flake github:UWE-FSAI/uweai-nix#vm-x86 --accept-flake-config
./result/bin/run-vm-x86-vm
```
