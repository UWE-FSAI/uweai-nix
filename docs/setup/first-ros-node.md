# Your first ROS project

By the end of this guide you'll have made your own ROS package with two
small programs that talk to each other, built it, and run it. It takes about
half an hour, and assumes you've never used ROS.

**Before you start**, you need a running system: the external SSD
([I have a PC or laptop](pc.md)), a VM ([PC](pc.md#option-2-a-virtual-machine)
or [Mac](mac.md#option-2-a-virtual-machine)), or [NixOS](nixos.md). Do
[First steps](first-steps.md) 1 and 2 (password, wifi). You don't need GitHub
for this guide.

On a Mac, use the VM: the Mac dev shell doesn't include ROS.

<details>
<summary>▶ What are nodes, topics and packages?</summary>

- **ROS** (Robot Operating System) is how the car's software is organised:
  many small programs that pass messages to each other.
- **Node:** one of those small programs. The car runs dozens: one reads the
  camera, one finds cones, one plans a path, one steers.
- **Topic:** a named channel that nodes send messages on, like
  `/chatter` or `/cones`. Any node can send to a topic and any node can
  listen to it. The sender doesn't know or care who's listening.
- **Message:** one piece of data sent on a topic. Here, a line of text.
- **Package:** a folder holding one or more nodes and a description of what
  they need. It's the unit you build and share.
- **Workspace:** a folder holding your packages, plus the results of
  building them.
- **colcon:** the tool that builds every package in a workspace.

</details>

## 1. Open a terminal and enter the ROS shell

Open **Konsole** (application menu, bottom left → search *Konsole*). Then
enter your department's shell, which has ROS and the tools to build with.
Use your department in place of `perception`; any department works for this
guide.

```bash
nix develop github:UWE-FSAI/uweai-nix#perception --accept-flake-config
```

When it's ready it prints a line starting *uweai-nix perception shell: ROS 2
jazzy*. The first time can take a few minutes; after that it's quick.

<details>
<summary>▶ How do I use the terminal (Konsole)?</summary>

Click in the window and type, or paste, a command, then press **Enter**.
To paste in Konsole, use **Ctrl + Shift + V**, or right-click → Paste. The
**Up arrow** brings back your last command. A command has finished when you
see a line ending in `$` again. **Ctrl + C** stops a command that's still
running.

</details>

<details>
<summary>▶ What's a "shell", and why do I need this one?</summary>

The shell is the program behind the terminal that reads your commands.
`nix develop` starts a new shell with extra tools added: ROS, the build tool
colcon, and your department's libraries, at exactly the versions everyone
else uses. They're only there in this terminal window. Type `exit` to leave
it.

</details>

## 2. Make a workspace

A workspace is just a folder with a `src` folder inside, where your packages
go:

```bash
mkdir -p ~/ros2_ws/src
cd ~/ros2_ws/src
```

<details>
<summary>▶ What do those two commands mean?</summary>

- `mkdir -p ~/ros2_ws/src` makes a folder called `ros2_ws` in your home
  folder (`~` means your home folder), with a folder called `src` inside it.
- `cd ~/ros2_ws/src` moves the terminal into that folder, so the next
  commands happen there. Type `pwd` at any time to see which folder you're
  in.

</details>

## 3. Create a package

```bash
ros2 pkg create hello_ros --build-type ament_python --license Apache-2.0 --dependencies rclpy std_msgs --node-name talker
```

It prints what it's creating. You now have a package called `hello_ros`,
written in Python, with one node called `talker` that just prints a
greeting. These are the files that matter:

```
~/ros2_ws/src/hello_ros/
├── package.xml        what the package is and what it needs
├── setup.py           how to build it, and the names of its nodes
└── hello_ros/
    └── talker.py      the talker node's code
```

<details>
<summary>▶ What did each part of that command mean?</summary>

- `hello_ros`: the package's name. Package names use lower case and
  underscores.
- `--build-type ament_python`: the package is written in Python. (C++
  packages use `ament_cmake`.)
- `--license Apache-2.0`: the licence the code is shared under.
- `--dependencies rclpy std_msgs`: it uses `rclpy`, ROS for Python, and
  `std_msgs`, ROS's standard message types such as text and numbers.
- `--node-name talker`: make a first node called `talker`.

</details>

## 4. Write the talker

Open the workspace in **VSCodium**, the code editor:

```bash
codium ~/ros2_ws
```

If it asks whether you trust the authors of the files, click **Yes, I trust
the authors** (you're the author). In the file list on the left, open
**src** → **hello_ros** → **hello_ros** → **talker.py**.

Select everything in it (**Ctrl + A**), delete it, and paste this in its
place:

```python
import rclpy
from rclpy.executors import ExternalShutdownException
from rclpy.node import Node
from std_msgs.msg import String


class Talker(Node):

    def __init__(self):
        super().__init__('talker')
        # Publish String messages on the topic called "chatter".
        self.publisher = self.create_publisher(String, 'chatter', 10)
        # Call say_hello every half a second.
        self.timer = self.create_timer(0.5, self.say_hello)
        self.count = 0

    def say_hello(self):
        msg = String()
        msg.data = f'Hello from UWE-AI: {self.count}'
        self.publisher.publish(msg)
        self.get_logger().info(f'Sent: "{msg.data}"')
        self.count += 1


def main():
    rclpy.init()
    node = Talker()
    try:
        rclpy.spin(node)
    except (KeyboardInterrupt, ExternalShutdownException):
        pass
    finally:
        node.destroy_node()
        rclpy.try_shutdown()


if __name__ == '__main__':
    main()
```

Save it with **Ctrl + S**.

<details>
<summary>▶ What does this code do?</summary>

- `class Talker(Node)` defines a node. `super().__init__('talker')` gives it
  the name *talker*, which is how it shows up in ROS's tools.
- `create_publisher(String, 'chatter', 10)` says the node will send text
  messages on the topic `chatter`. The `10` is how many messages to hold if
  they can't be sent straight away.
- `create_timer(0.5, self.say_hello)` makes ROS call `say_hello` every 0.5
  seconds.
- `say_hello` builds a message, sends it with `publish`, and logs it so you
  can see it in the terminal.
- `main` is what runs when you start the node. `rclpy.init()` connects to
  ROS, and `rclpy.spin(node)` keeps the node running, calling its timer,
  until you press Ctrl + C. The rest shuts it down tidily.

</details>

## 5. Build it

Go back to Konsole. Builds always run from the top of the workspace:

```bash
cd ~/ros2_ws
colcon build --symlink-install
```

It should end with **Summary: 1 package finished**. If it printed red
errors instead, see [Something went wrong](#something-went-wrong).

<details>
<summary>▶ What did building do?</summary>

colcon made three folders next to `src`: `build` (working files), `install`
(the finished package, which is what ROS runs) and `log` (a record of the
build). You can delete all three at any time and build again.

`--symlink-install` makes the installed package point at your code in `src`
rather than copying it. So when you edit a Python file, you only need to run
the node again to see the change, not build again.

</details>

## 6. Run it

```bash
source install/setup.bash
ros2 run hello_ros talker
```

It prints a new line every half a second:

```
[INFO] [1760000000.123456789] [talker]: Sent: "Hello from UWE-AI: 0"
[INFO] [1760000000.623456789] [talker]: Sent: "Hello from UWE-AI: 1"
```

Your node is running and sending messages. **Leave it running** for the next
step.

<details>
<summary>▶ What does "source install/setup.bash" do?</summary>

It tells this terminal about the packages in your workspace, so
`ros2 run` can find `hello_ros`. You need it once in each new terminal, and
again after a build that adds something new (a new node or package).

</details>

## 7. Watch it from a second terminal

Open a second tab in Konsole: **File** → **New Tab** (or **Ctrl + Shift +
T**). A new tab is a fresh terminal, so it needs the same set-up lines:

```bash
cd ~/ros2_ws
nix develop github:UWE-FSAI/uweai-nix#perception --accept-flake-config
source install/setup.bash
```

> **Every new terminal needs those three lines** before ROS commands work:
> go to the workspace, enter the shell, and `source` the workspace. Press
> the **Up arrow** to find them again rather than retyping.

Now ask ROS what's going on:

```bash
ros2 node list
ros2 topic list
ros2 topic echo /chatter
```

- `ros2 node list` shows `/talker`, your node.
- `ros2 topic list` shows `/chatter` (and two topics ROS always has).
- `ros2 topic echo /chatter` prints each message as it arrives, like
  `data: 'Hello from UWE-AI: 42'`. Press **Ctrl + C** to stop watching.

## 8. Add a second node that listens

Real ROS nodes don't print to a person, they talk to other nodes. Add a
listener.

1. In VSCodium, right-click the inner **hello_ros** folder (the one holding
   `talker.py`) → **New File…**, name it `listener.py`, and paste:

   ```python
   import rclpy
   from rclpy.executors import ExternalShutdownException
   from rclpy.node import Node
   from std_msgs.msg import String


   class Listener(Node):

       def __init__(self):
           super().__init__('listener')
           # Call heard every time a message arrives on "chatter".
           self.subscription = self.create_subscription(String, 'chatter', self.heard, 10)

       def heard(self, msg):
           self.get_logger().info(f'Heard: "{msg.data}"')


   def main():
       rclpy.init()
       node = Listener()
       try:
           rclpy.spin(node)
       except (KeyboardInterrupt, ExternalShutdownException):
           pass
       finally:
           node.destroy_node()
           rclpy.try_shutdown()


   if __name__ == '__main__':
       main()
   ```

   Save it (**Ctrl + S**).

2. Tell the package about the new node. Open **setup.py** (in the outer
   `hello_ros` folder) and find these lines near the bottom:

   ```python
           'console_scripts': [
               'talker = hello_ros.talker:main'
           ],
   ```

   Add a comma after the talker line, and a line for the listener, so it
   reads:

   ```python
           'console_scripts': [
               'talker = hello_ros.talker:main',
               'listener = hello_ros.listener:main',
           ],
   ```

   Save it.

3. In the **second** Konsole tab, build again (a new node always needs a
   build) and run the listener:

   ```bash
   colcon build --symlink-install
   source install/setup.bash
   ros2 run hello_ros listener
   ```

With the talker still running in the first tab, the listener prints what it
hears:

```
[INFO] [1760000100.123456789] [listener]: Heard: "Hello from UWE-AI: 212"
```

That's two ROS nodes talking over a topic, which is how every part of the
car works. Press **Ctrl + C** in each tab to stop them.

## 9. Change it and run it again

Try changing the message, or `0.5` to `0.1` to send ten a second. Save,
press **Ctrl + C** on the talker, and run it again with the Up arrow. With
`--symlink-install` you don't need to build again for changes like this.

| You changed | Then |
|---|---|
| Code in a Python file that's already there | Stop the node and run it again |
| `setup.py` or `package.xml` (for example, a new node) | `colcon build --symlink-install`, then `source install/setup.bash`, then run it |

To come back another day: open Konsole, run the three set-up lines from
step 7, then `ros2 run hello_ros talker`.

## Something went wrong

<details>
<summary>▶ "ros2: command not found" or "colcon: command not found"</summary>

This terminal isn't in the ROS shell. Run the `nix develop …` line from
step 1. Each new tab or window needs it.

</details>

<details>
<summary>▶ "Package 'hello_ros' not found"</summary>

This terminal doesn't know about your workspace yet. Run
`cd ~/ros2_ws` and then `source install/setup.bash`. If it still says
this, the build didn't finish: run `colcon build --symlink-install` and look
for errors.

</details>

<details>
<summary>▶ "No executable found"</summary>

ROS found the package but not that node. If it's a node you just added,
check the line in `setup.py` (spelling, and a comma at the end of each line),
then build and `source` again.

</details>

<details>
<summary>▶ The build failed, mentioning setup.py or a SyntaxError</summary>

Usually a missing comma or quote mark in `setup.py`, or a paste that lost
its indentation in a `.py` file. Python cares about indentation: the lines
inside `class` and `def` must be indented exactly as shown. The error names
the file and line number to look at.

</details>

<details>
<summary>▶ The listener runs but hears nothing</summary>

Check the talker is still running in the other tab, and that both use the
same topic name, `chatter`. Both must be on the same computer: the society's
setup keeps ROS traffic on your own machine so you don't see (or interfere
with) other people's nodes on university wifi.

</details>

## Next: your own package in the team's code

When you're ready to work on the real code, do [First steps](first-steps.md)
4 and 5 (GitHub key, getting the code). Then tell git your name, once:

```bash
git config --global user.name "Your Name"
git config --global user.email "the-email-on-your-github-account@example.com"
```

New packages go in your department's folder under `src/`: `Integration`,
`Perception`, `SLAM` or `VehicleDevelopment`. Check the name with your department
lead first. Enter the workspace's own shell (it has the same ROS as this
guide's), using your department:

```bash
cd ~/ads-ws && nix develop .#perception --accept-flake-config
```

Then:

```bash
cd ~/ads-ws/src/Perception
ros2 pkg create my_package --build-type ament_python --license Apache-2.0 --dependencies rclpy std_msgs --node-name my_node
cd ~/ads-ws
colcon build --symlink-install --packages-up-to my_package
source install/setup.bash
ros2 run my_package my_node
```

`--packages-up-to my_package` builds just your package and what it needs,
not the whole workspace.

To share it, save it on a *branch* of your own and send it to GitHub:

```bash
git switch -c add-my-package
git add src/Perception/my_package
git commit -m "Add my_package"
git push -u origin add-my-package
```

The push prints a link: open it to create a *pull request*, which asks for
your work to be reviewed and added to the main code. If the push says
*permission denied*, ask a project lead to give your GitHub account access.

<details>
<summary>▶ What are branches, commits and pull requests?</summary>

- **Commit:** a saved snapshot of your changes, with a message saying what
  you did.
- **Branch:** your own line of commits, separate from everyone else's, so
  you can work without breaking the main code.
- **Pull request:** a request on GitHub to merge your branch into the main
  code. Others can read it, comment and approve it first.

</details>

To learn more ROS, the official
[ROS 2 Jazzy tutorials](https://docs.ros.org/en/jazzy/Tutorials.html) go
further. Use this guide's shell in place of their installation and
*sourcing* steps, which are for Ubuntu.
