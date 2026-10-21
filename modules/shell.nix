# The society's terminal setup, ported from UWE-FSAI/config-files: bash
# aliases and helpers, git, tmux, fzf and bat, all expressed in Nix. No editor
# configuration is shipped: bring your own (~/.config/nvim and so on).
#
# Everything is a default. Each tool writes a system-wide file (/etc/gitconfig,
# /etc/tmux.conf, /etc/bat/config, /etc/bashrc) that your own ~/.gitconfig,
# ~/.tmux.conf, ~/.config/bat/config or ~/.bashrc is read after, so a personal
# dotfile always wins. In Nix, a plain assignment beats any value here, and
# each piece turns off on its own (`ads.shell.tmux.enable = false;`). See
# docs/setup/customising.md.
{ config, lib, pkgs, ... }:
let
  cfg = config.ads.shell;

  # Each leaf at default priority, so a plain assignment to any one setting
  # wins without discarding the rest.
  defaults = lib.mapAttrsRecursive (_: lib.mkDefault);

  gitAliases = {
    st = "status";
    ci = "commit";
    cm = "commit";
    br = "branch";
    co = "checkout";
    df = "diff";
    lg = "log --oneline --graph --decorate --all";
    last = "log -1 HEAD";
    unstage = "reset HEAD --";
  };

  # Helpers that don't need to change the current shell are commands, so they
  # work from any shell and script. writeShellApplication shellchecks each one
  # at build time.
  script = name: runtimeInputs: text: pkgs.writeShellApplication { inherit name runtimeInputs text; };

  bashScripts = with pkgs; [
    (script "extract" [ gnutar bzip2 gzip unzip ] ''
      if [ ! -f "''${1-}" ]; then
        echo "not a valid file: ''${1-}" >&2
        exit 1
      fi
      case "$1" in
        *.tar.bz2 | *.tbz2) tar xjf "$1" ;;
        *.tar.gz | *.tgz) tar xzf "$1" ;;
        *.tar) tar xf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.gz) gunzip "$1" ;;
        *.zip) unzip "$1" ;;
        *.rar) unrar e "$1" ;;
        *.7z) 7z x "$1" ;;
        *.Z) uncompress "$1" ;;
        *)
          echo "'$1' cannot be extracted by extract" >&2
          exit 1
          ;;
      esac
    '')
  ];

  tmuxScripts = [
    (script "tls" [ pkgs.tmux ] "tmux ls")
    (script "tmake" [ pkgs.tmux ] ''tmux new -s "$1"'')
  ];

  # The editor may be a command with arguments ("codium --wait"), so it is
  # word-split on purpose (SC2086).
  fzfScripts = with pkgs; [
    # Find a file by name and open it.
    (script "ff" [ fzf bat ] ''
      file=$(fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}' \
        --preview-window=right:60%:wrap)
      # shellcheck disable=SC2086
      exec ''${EDITOR:-nano} "$file"
    '')
    # Find in files: search contents, open the match at its line. (Called
    # `fg` in config-files, which hid bash's job-control fg.)
    (script "fif" [ ripgrep fzf bat ] ''
      rg --color=always --line-number --no-heading --smart-case "''${*:-}" |
        fzf --ansi \
          --delimiter ':' \
          --preview 'bat --color=always --highlight-line {2} --line-range {2}: {1}' \
          --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
          --bind "enter:become(''${EDITOR:-nano} +{2} {1})"
    '')
    # Pick a git branch and check it out.
    (script "fgb" [ git fzf gnused gnugrep coreutils ] ''
      branch=$(git branch -a | grep -v HEAD | sed 's/.* //' | sed 's#remotes/origin/##' |
        sort -u | fzf --preview 'git log --oneline --graph --decorate --color=always {}' \
          --preview-window=right:60%)
      git checkout "''${branch#origin/}"
    '')
    # Pick processes and kill them (signal as $1, TERM by default).
    (script "fkill" [ procps fzf gawk gnused findutils ] ''
      pid=$(ps aux | sed 1d | fzf -m | awk '{print $2}')
      if [ -n "$pid" ]; then
        echo "$pid" | xargs kill "-''${1:-TERM}"
      fi
    '')
    # ripgrep for a pattern, pick a match, open it at its line.
    (script "frg" [ ripgrep fzf bat gawk ] ''
      if [ $# -eq 0 ]; then
        echo "Usage: frg <search_pattern>" >&2
        exit 1
      fi
      match=$(rg --color=always --line-number --no-heading "$@" |
        fzf --ansi \
          --delimiter=: \
          --preview 'bat --color=always --highlight-line {2} {1}' \
          --preview-window='right:60%:+{2}-/2')
      file=$(echo "$match" | awk -F: '{print $1}')
      line=$(echo "$match" | awk -F: '{print $2}')
      # shellcheck disable=SC2086
      exec ''${EDITOR:-nano} "+$line" "$file"
    '')
  ];
in
{
  options.ads.shell = {
    enable = lib.mkEnableOption "the society's terminal setup (bash, git, tmux, fzf, bat)";

    editor = lib.mkOption {
      type = lib.types.str;
      default = "nano";
      example = "nvim";
      description = ''
        Default editor (EDITOR and VISUAL), used by git, sudoedit and the fzf
        helpers. nano on developer machines, nvim on the car. An `export
        EDITOR=...` in your own ~/.bashrc still wins.
      '';
    };

    bash.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Aliases (ll, la, .., df -h, g<git alias>, ...), history settings, mkcd and extract.";
    };

    git.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "System git settings: aliases (st, co, lg, ...), colours, main as the default branch.";
    };

    tmux.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "tmux with Ctrl-a as the prefix, gruvbox, sessions saved and restored (resurrect, continuum), and ta / tls / tmake.";
    };

    fzf.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "fzf key bindings (Ctrl-T, Ctrl-R, Alt-C), its colours, and helpers (ff, fif, fcd, fgb, fkill, frg).";
    };

    bat.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "bat, a cat with syntax highlighting, with the society theme.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # One step above NixOS's own `mkDefault "nano"`, and below the 900 that
      # programs.{vim,neovim}.defaultEditor use, so those and any plain
      # assignment still win.
      environment.variables.EDITOR = lib.mkOverride 950 cfg.editor;
      environment.variables.VISUAL = lib.mkOverride 950 cfg.editor;
    }

    (lib.mkIf cfg.bash.enable {
      # Above NixOS's own mkDefault ll/l, below a plain assignment. Set one
      # to null to remove it.
      environment.shellAliases = lib.mapAttrs (_: lib.mkOverride 950) {
        ll = "ls -alF --color=auto";
        la = "ls -A --color=auto";
        l = "ls -CF --color=auto";
        lt = "ls -ltr --color=auto";
        lh = "ls -lah --color=auto";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        df = "df -h";
        du = "du -h";
        free = "free -h";
        rm = "rm -i";
        cp = "cp -i";
        mv = "mv -i";
      };
      # History. Plain shell variables, so ~/.bashrc can still change them.
      environment.variables = lib.mapAttrs (_: lib.mkDefault) {
        HISTCONTROL = "ignoreboth";
        HISTSIZE = "10000";
        HISTFILESIZE = "20000";
      };
      environment.systemPackages = bashScripts;
      # Changes the current directory, so it has to be a shell function.
      programs.bash.interactiveShellInit = ''
        shopt -s histappend checkwinsize
        mkcd() { mkdir -p "$1" && cd "$1" || return; }
      '';
    })

    # Each society git alias as a g-prefixed command: `gst` runs `git st`.
    (lib.mkIf (cfg.bash.enable && cfg.git.enable) {
      environment.shellAliases = lib.mapAttrs' (name: _:
        lib.nameValuePair "g${name}" (lib.mkOverride 950 "git ${name}")) gitAliases;
    })

    (lib.mkIf cfg.git.enable {
      programs.git.enable = lib.mkDefault true;
      programs.git.config = defaults {
        init.defaultBranch = "main";
        color = {
          ui = "auto";
          branch = { current = "magenta bold"; local = "blue"; remote = "green"; };
          diff = { meta = "yellow bold"; frag = "magenta bold"; old = "red bold"; new = "green bold"; };
          status = { added = "green"; changed = "yellow"; untracked = "cyan"; };
        };
        alias = gitAliases;
        push.default = "simple";
        pull.rebase = false;
        merge.tool = "nvimdiff";
        diff.tool = "nvimdiff";
      };
    })

    (lib.mkIf cfg.tmux.enable {
      programs.tmux = {
        enable = lib.mkDefault true;
        shortcut = lib.mkDefault "a";
        baseIndex = lib.mkDefault 1;
        terminal = lib.mkDefault "screen-256color";
        plugins = lib.mkDefault (with pkgs.tmuxPlugins; [ sensible gruvbox resurrect continuum ]);
        extraConfigBeforePlugins = lib.mkDefault ''
          set -g @resurrect-processes 'python sqlite3 nano nvim'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @continuum-restore 'on'
        '';
        extraConfig = lib.mkDefault ''
          bind r source-file /etc/tmux.conf \; display-message "Reloaded /etc/tmux.conf"
          set -g renumber-windows on
          set -gq allow-passthrough on
          bind | split-window -h
          bind - split-window -v
        '';
      };
      environment.systemPackages = tmuxScripts;
      # Attaching takes over the current terminal, so it stays a function.
      programs.bash.interactiveShellInit = ''
        ta() { tmux attach -t "$1"; }
      '';
    })

    (lib.mkIf cfg.fzf.enable {
      programs.fzf.keybindings = lib.mkDefault true;
      programs.fzf.fuzzyCompletion = lib.mkDefault true;
      environment.systemPackages = [ pkgs.fd pkgs.bat pkgs.tree ] ++ fzfScripts;
      environment.variables = lib.mapAttrs (_: lib.mkDefault) {
        # CleanDark OLED colours
        FZF_DEFAULT_OPTS = lib.concatStringsSep " " [
          "--color=bg:#000000,bg+:#0a0a0a,fg:#d4d4d4,fg+:#ffffff"
          "--color=hl:#400080,hl+:#400080,info:#569cd6,prompt:#400080,pointer:#400080"
          "--color=marker:#400080,spinner:#400080,header:#400080,border:#400080,gutter:#000000"
          "--border --height=40% --layout=reverse --info=inline"
          "--prompt='> ' --pointer='>' --marker='+'"
        ];
        FZF_DEFAULT_COMMAND = ''rg --files --hidden --follow --glob "!.git/*"'';
        FZF_CTRL_T_COMMAND = ''rg --files --hidden --follow --glob "!.git/*"'';
        FZF_ALT_C_COMMAND = "fd --type d --hidden --follow --exclude .git";
        FZF_CTRL_T_OPTS = "--preview 'bat --color=always --style=numbers --line-range=:500 {}' --preview-window=right:60%:wrap";
        FZF_ALT_C_OPTS = "--preview 'tree -C {} | head -200' --preview-window=right:60%";
      };
      # Changes the current directory, so it has to be a shell function.
      programs.bash.interactiveShellInit = ''
        fcd() {
          local dir
          dir=$(fd --type d --hidden --follow --exclude .git |
            fzf --preview 'tree -C {} | head -200' --preview-window=right:60%) || return
          cd "$dir" || return
        }
      '';
    })

    (lib.mkIf cfg.bat.enable {
      programs.bat.enable = lib.mkDefault true;
      programs.bat.settings = defaults {
        theme = "TwoDark";
        style = "numbers,changes,header";
        paging = "auto";
        wrap = "auto";
        italic-text = "always";
        tabs = "4";
      };
    })
  ]);
}
