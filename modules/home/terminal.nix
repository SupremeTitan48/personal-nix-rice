# modules/home/terminal.nix
{ config, pkgs, lib, ... }:
{
  programs.foot = {
    enable = true;
    package = pkgs.foot;
    settings = {
      main = {
        shell = "fish";
        term = "xterm-256color";
        title = "foot";
        font = "JetBrainsMono Nerd Font:size=11";
        letter-spacing = 0;
        dpi-aware = "no";
        pad = "25x25";
        bold-text-in-bright = "no";
      };
      scrollback.lines = 10000;
      cursor = {
        style = "beam";
        blink = "no";
        beam-thickness = 1.5;
      };
      key-bindings = {
        scrollback-up-page = "Page_Up";
        scrollback-down-page = "Page_Down";
        clipboard-copy = "Control+c";
        clipboard-paste = "Control+v";
        search-start = "Control+f";
        font-increase = "Control+plus Control+equal Control+KP_Add";
        font-decrease = "Control+minus Control+KP_Subtract";
        font-reset = "Control+0 Control+KP_0";
      };
      search-bindings = {
        cancel = "Escape";
        find-prev = "Shift+F3";
        find-next = "F3 Control+G";
        delete-prev-word = "Control+BackSpace";
      };
      text-bindings."\\x03" = "Control+Shift+c";
    };
  };

  programs.fish = {
    enable = true;
    package = pkgs.fish;

    plugins = [
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
    ];

    shellAliases = {
      ls = "eza --icons --color=always --group-directories-first";
      ll = "eza -la --icons --color=always --group-directories-first";
      lt = "eza --tree --icons --color=always --level 2";
      cat = "bat --style=auto";
      nrs = "sudo nixos-rebuild switch --flake $FLAKE_DIR#desktop";
      nrt = "sudo nixos-rebuild test --flake $FLAKE_DIR#desktop";
    };

    interactiveShellInit = ''
      set -g fish_greeting ""

      # any-nix-shell: keep fish when entering nix-shell / nix develop
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

      # Fish syntax highlighting uses ANSI names so generated terminal colors
      # can remap the palette without rewriting shell config.
      set -g fish_color_command magenta
      set -g fish_color_param normal
      set -g fish_color_keyword yellow
      set -g fish_color_quote green
      set -g fish_color_redirection cyan
      set -g fish_color_end brblack
      set -g fish_color_error red
      set -g fish_color_comment brblack
      set -g fish_color_autosuggestion brblack
      set -g fish_color_operator yellow
      set -g fish_color_escape yellow
      set -g fish_color_selection --background=brblack
      set -g fish_pager_color_selected_background --background=brblack
    '';
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      format = "$os$directory$git_branch$git_status$nix_shell$cmd_duration$line_break$character";
      os = {
        disabled = false;
        style = "bold blue";
      };
      directory = {
        style = "bold cyan";
        truncation_length = 3;
      };
      git_branch = {
        style = "bold magenta";
        format = "[$symbol$branch]($style) ";
      };
      git_status = {
        style = "yellow";
        format = "[$all_status$ahead_behind]($style) ";
      };
      nix_shell = {
        style = "cyan";
        format = "[$symbol$state]($style) ";
      };
      cmd_duration = {
        min_time = 2000;
        style = "bright-black";
      };
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    defaultOptions = [ "--height 40%" "--layout=reverse" "--border" "--color=dark" ];
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      auto_sync = false;
      update_check = false;
      style = "compact";
      history_filter = [ "^nrs" "^nrt" ];
    };
  };

  programs.bat = {
    enable = true;
    config.theme = "TwoDark";
  };

  programs.nix-index = {
    enable = true;
    enableFishIntegration = true;
  };

  # command-not-found conflicts with nix-index's own handler
  programs.command-not-found.enable = false;

  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "code";
    FLAKE_DIR = "/etc/nixos";  # install.sh clones the repo here
    MANPAGER = "sh -c 'col -bx | bat -l man -p'";
  };

  home.packages = with pkgs; [
    eza
    fd               # fzf works better with fd as the finder backend
    playerctl
    any-nix-shell
  ];
}
