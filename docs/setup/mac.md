# I have a Mac

> **Nothing on your Mac is erased or replaced.**
>
> macOS stays exactly as it is. The dev shell installs a tool called Nix,
> like installing an app, and the virtual machine is a file you can delete
> whenever you like. You don't need a USB drive for either.

There are two ways to work on a Mac. You can have both, except on an Intel
Mac, where only the VM works.

- **Your department's dev shell** (start here). Your department's tools,
  running directly on macOS, set up with one command. It doesn't include
  ROS, which doesn't work reliably on macOS. Good for perception and
  training work, path planning and SLAM maths, scripts and docs.
- **A virtual machine (VM).** The society's full Linux system, including ROS,
  RViz and Gazebo, running in a window. Use it when you need to run ROS.

This guide assumes you've never used Linux or the Terminal. Anything marked
with ▶ opens when you click it, for extra help if you need it.

<details>
<summary>▶ New to all this? A few words explained</summary>

- **Terminal:** an app on your Mac where you type commands instead of
  clicking. This guide gives you every command, exactly.
- **Nix:** a tool that installs exactly the same versions of software for
  everyone, so your setup matches the rest of the team.
- **Dev shell:** a Terminal window with your department's tools added. When
  you close it, they're out of the way again.
- **Linux / NixOS:** an operating system, like macOS. NixOS is the version of
  Linux the society uses.
- **Virtual machine (VM):** a pretend computer running in a window on your
  Mac. It has its own pretend drive, which is really one big file.
- **ROS:** the Robot Operating System, the software framework the car's code
  is built on.

</details>

<details>
<summary>▶ How to use the Terminal</summary>

- **Open it:** press **Cmd + Space**, type **Terminal**, press **Enter**.
- **Run a command:** click in the window, paste the command with **Cmd + V**
  (or type it), and press **Enter**.
- **When it asks for a password:** type your Mac's login password and press
  Enter. **Nothing appears as you type**, not even dots. That's normal.
- **Finished?** A command is done when you see the prompt again, a line
  ending in `%` or `$`.

</details>

## Which Mac do you have?

Click the **Apple menu** (top left) → **About This Mac**.

- **Chip: Apple M1, M2, M3, M4…** — an *Apple Silicon* Mac. Most Macs from
  2021 onwards.
- **Processor: Intel…** — an *Intel* Mac.

The dev shell (Option 1) needs Apple Silicon. On an Intel Mac, go
straight to [Option 2](#option-2-a-virtual-machine). Where the VM steps
differ, they say so.

## Option 1: your department's dev shell

### Step 1: Install Nix

1. Open **Terminal** and paste:
   ```bash
   sh <(curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install)
   ```
2. It explains what it's going to do and asks some questions: answer **y**
   and press Enter each time. When it asks for a password, use your Mac's
   login password.
3. When it says it's finished, paste these three lines and press Enter. They
   switch on the features the society's setup uses:
   ```bash
   echo "experimental-features = nix-command flakes" | sudo tee -a /etc/nix/nix.conf
   echo "trusted-users = root $USER" | sudo tee -a /etc/nix/nix.conf
   sudo launchctl kickstart -k system/org.nixos.nix-daemon
   ```
4. **Quit Terminal completely** (Cmd + Q) and open it again. Check Nix is
   there:
   ```bash
   nix --version
   ```
   It should print something like `nix (Nix) 2.xx`.

<details>
<summary>▶ What did that just do to my Mac?</summary>

It added a separate storage area on your Mac's drive called *Nix Store*,
where all the tools live, apart from macOS's own files. Your files and apps
aren't touched. If you ever want to remove it, ask a project lead; there's
an uninstall procedure.

</details>

### Step 2: Open your department's shell

Pick your department from `integration`, `perception`, `slam` or
`vehicle-development`, and use it in place of `perception` below. This
opens it straight from uweai-nix; once you have the code
([First steps](first-steps.md) 4 to 6), open it from `~/ads-ws` instead, so
you get the versions the code was tested with.

```bash
nix develop github:UWE-FSAI/uweai-nix#perception --accept-flake-config
```

The first time, it downloads everything your department uses, which can
take a while. After that it opens in seconds. When it's ready it prints a
line starting *uweai-nix perception shell*.

You're now "in" the shell: your department's tools work in this Terminal
window. Type `exit` to leave it. To get back in another time, run the same
`nix develop` command.

### Step 3: Check it works

```bash
python3 -c "import numpy, scipy; print('ok')"
```

It should print `ok`. In the perception shell you can also check PyTorch
and Ultralytics:

```bash
python3 -c "import torch, ultralytics; print(torch.__version__)"
```

Now continue with [First steps](first-steps.md) 4 to 7 to get the code.
Steps 1 to 3 are for the SSD and VM only.

## Option 2: a virtual machine

This gives you the society's full system, with ROS, in a window. You need
about **70 GB of free space** and **8 GB of memory** or more (16 GB is
comfortable).

<details>
<summary>▶ How do I check my free space and memory?</summary>

Apple menu → **About This Mac**. *Memory* shows your memory. For space, click
**More Info…** → **Storage** (or Apple menu → System Settings → General →
Storage).

</details>

### Step 1: Install UTM and download NixOS

1. Install **UTM** from [mac.getutm.app](https://mac.getutm.app). It's free:
   click **Download**, open the downloaded file, and drag UTM into
   Applications.
2. Go to [nixos.org/download](https://nixos.org/download). Under *NixOS: the
   Linux distribution*, download the **Minimal ISO image**:
   - Apple Silicon Mac: **64-bit ARM**
   - Intel Mac: **64-bit Intel/AMD**

   It's a single file ending in `.iso`, in your Downloads folder. Not the
   *Graphical* one: these guides are written for the minimal one.

### Step 2: Create the VM

Open UTM and:

1. Click **+** (or *Create a New Virtual Machine*) → **Virtualize** →
   **Linux**.
2. Under *Boot ISO Image*, click **Browse** and choose the `.iso` you
   downloaded. Leave the other options as they are. **Continue**.
3. Memory: **4096 MB** (or **8192** if your Mac has 16 GB or more). CPU
   Cores: **4**. **Continue**.
4. Storage: **64** GB. **Continue**. On *Shared Directory*, just
   **Continue**.
5. Name it `uweai` and click **Save**.
6. Optional, for a smoother desktop: select the VM, click the settings icon
   (sliders) at the top, choose **Display**, and pick the emulated display
   card whose name ends in *(GPU Supported)*. **Save**.

### Step 3: Install NixOS into the VM

1. Select the VM and click the big **▶ play** button. Press **Enter** on the
   first option in the NixOS menu. Text scrolls past for a minute, then
   stops at a line ending `[nixos@nixos:~]$`. That's the *prompt*, waiting
   for a command. The installer is text only, with no desktop or mouse. It's
   already logged in, and its internet works automatically.
2. Type this command carefully, as one long line: you can't paste into the
   VM yet. Keep typing when you reach the edge of the screen, and press
   Enter only at the end. On an **Intel Mac**, use `vm-x86` instead of
   `vm-aarch64`:
   ```bash
   sudo nix --extra-experimental-features 'nix-command flakes' run --accept-flake-config github:UWE-FSAI/uweai-nix#ads-install -- vm-aarch64 /dev/vda
   ```
   The installer uses a US keyboard layout, so on a UK Mac keyboard `#` is
   **Shift + 3**. The
   [PC guide](pc.md#step-6-install-onto-the-ssd) explains each piece of the
   command, under *Typing it in pieces*.
   `/dev/vda` is the VM's own pretend drive. Your Mac's drive can't be seen
   from inside the VM at all.
3. It shows the drive it's about to use (64 GB) and asks you to type its
   name. Type `/dev/vda` and press Enter.
4. Wait. It downloads several GB into the VM, usually 15 to 45 minutes.
   When it prints **Done**, type `poweroff` and press Enter.
5. Back in UTM, with the VM selected, find **CD/DVD** in the panel on the
   right (it shows the `.iso` name), click it, and choose **Clear**. This
   stops the VM starting the installer again.

<details>
<summary>▶ I made a typo / it printed an error</summary>

Press the **Up arrow** key to bring the command back, fix it with the
arrow keys, and press Enter again. If it printed **STOPPED**, nothing was
changed: read the line after it. If you're stuck, take a photo of the
screen and ask a project lead.

</details>

### Step 4: Start the VM

Click **▶ play** again. You'll get a login screen. Log in as **`uweai`**
with password **`uwe-fsai`**.

To shut the VM down, use the menu in its bottom-left corner → **Shut
Down**, as you would a real computer. To remove it entirely, delete it in
UTM: that deletes its file and frees the space.

Now continue with [First steps](first-steps.md), starting by changing that
password.
