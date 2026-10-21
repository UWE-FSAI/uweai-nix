# Changing the defaults

Everything the society configuration sets is a default. Your own settings
always win, and nothing you set is ever overwritten by `ads-update`.

There are two places your settings can go:

- **Your own dotfiles** (`~/.bashrc`, `~/.gitconfig`, `~/.tmux.conf`,
  `~/.config/bat/config`). These are read after the society's system-wide
  files, so they win without touching Nix at all.
- **Nix**: `/etc/nixos/local.nix` on a machine installed from the society's
  SSD or VM image, or your own flake's `local.nix` if you
  [already use NixOS](nixos.md). Any plain assignment there beats the
  society's value. After editing, apply it with `ads-apply` (or
  `sudo nixos-rebuild switch --flake /etc/nixos#<name>` on your own flake).

Edit local.nix with `sudo nano /etc/nixos/local.nix`. The file already has
commented examples: remove the `#` at the start of a line to use one.

## The default editor

This is the editor git opens for commit messages, plus `sudoedit` and the
fzf helpers. It's `nano` on developer machines and `nvim` on the car. Both
are always installed.

To change it for the whole machine, in local.nix:

```nix
ads.shell.editor = "nvim";     # or "vim", "emacs", "nano", "codium --wait"
```

To change it for just yourself, without Nix, in `~/.bashrc`:

```bash
export EDITOR=nvim VISUAL=nvim
```

Git can also have its own editor, which beats both:
`git config --global core.editor nvim`.

## The terminal setup

The `shell` module sets up bash, git, tmux, fzf and bat, as ported from the
society's old config-files repository. Turn off any part of it, or
all of it, in local.nix:

```nix
ads.shell.bash.enable = false;     # aliases (ll, .., rm -i, gst, ...), mkcd, extract
ads.shell.git.enable = false;      # /etc/gitconfig aliases and colours
ads.shell.tmux.enable = false;     # Ctrl-a prefix, gruvbox, session restore, ta / tls / tmake
ads.shell.fzf.enable = false;      # fzf keys, colours, ff / fif / fcd / fgb / fkill / frg
ads.shell.bat.enable = false;      # bat theme
ads.shell.enable = false;          # all of the above
```

Or change a single setting and keep the rest:

```nix
# One alias: change it, or remove it with null
environment.shellAliases.rm = null;
environment.shellAliases.ll = "ls -la";

# One git setting
programs.git.config.pull.rebase = true;

# tmux with Ctrl-b, its usual prefix
programs.tmux.shortcut = "b";

# bat theme
programs.bat.settings.theme = "GitHub";
```

### Editors

No editor configuration comes with the society setup. `nano`, `vim`,
`neovim` and `emacs` are installed with their own defaults, so bring your
own config (`~/.config/nvim`, `~/.vimrc`, `~/.emacs.d`) if you have one.

## Other common changes

```nix
# Different desktop: "plasma" (default), "gnome", "xfce" or "none"
ads.desktop.environment = "gnome";

# Replace the core tool set, or add to it
ads.base.packages = with pkgs; [ git vim curl ];
ads.base.extraPackages = with pkgs; [ btop ];

# Your account's groups: add some, or replace the list
ads.user.extraGroups = [ "docker" ];
ads.user.groups = [ "wheel" "networkmanager" ];

# Fonts on the desktop
ads.desktop.fonts = with pkgs; [ noto-fonts ];
```

If Nix ever reports that an option "has conflicting definition values", the
society has set that one more strongly than a default. That's deliberate
only for SSH's key-only login (no passwords, no root) and the car's `adsdv`
service. Tell a project lead, because everything else is meant to give way
to a plain assignment.
