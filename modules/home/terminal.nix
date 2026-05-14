# modules/home/terminal.nix
{ config, pkgs, lib, ... }:
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;

    font = {
      name = "JetBrains Mono";
      size = 13;
    };

    settings = {
      # Window
      window_padding_width = 12;
      hide_window_decorations = "yes";
      confirm_os_window_close = 0;

      # Background transparency — wallpaper bleeds through floating terminal
      background_opacity = "0.85";
      dynamic_background_opacity = "yes";

      # Performance
      repaint_delay = 8;
      sync_to_monitor = "yes";

      # Cursor
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";

      # Scrollback
      scrollback_lines = 10000;

      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0";

      # Shell integration
      shell_integration = "enabled";
    };

    # Colors come from matugen — imported at runtime
    extraConfig = ''
      # Include matugen-generated color scheme
      include /home/jkoch/.cache/matugen/kitty-colors.conf
    '';
  };

  programs.fish = {
    enable = true;
    package = pkgs.fish;

    interactiveShellInit = ''
      # Suppress fish greeting
      set -g fish_greeting ""

      # Initialize starship prompt
      starship init fish | source

      # Better ls/cat with eza and bat
      alias ls 'eza --icons --color=always --group-directories-first'
      alias ll 'eza -la --icons --color=always --group-directories-first'
      alias lt 'eza --tree --icons --color=always --level 2'
      alias cat 'bat --style=auto'

      # Nix shorthand
      alias nrs 'sudo nixos-rebuild switch --flake ~/personal-nix-rice#desktop'
      alias nrt 'sudo nixos-rebuild test --flake ~/personal-nix-rice#desktop'

      # Wallpaper shorthand
      alias wp 'change-wallpaper'
    '';
  };

  programs.starship = {
    enable = true;
    package = pkgs.starship;

    settings = {
      format = lib.concatStrings [
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "$character"
      ];

      directory = {
        style = "bold blue";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
      };

      nix_shell = {
        symbol = " ";
        style = "bold cyan";
        format = "[$symbol$state]($style) ";
      };

      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
        format = "[$duration]($style) ";
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };
    };
  };

  home.packages = with pkgs; [
    eza
    bat
    playerctl    # media key support
  ];
}
