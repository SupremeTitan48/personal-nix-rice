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
      include ${config.home.homeDirectory}/.cache/matugen/kitty-colors.conf
    '';
  };

  programs.fish = {
    enable = true;
    package = pkgs.fish;

    plugins = [
      { name = "tide"; src = pkgs.fishPlugins.tide.src; }
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
    ];

    # Abbreviations expand inline — better than aliases for discoverability
    shellAbbrs = {
      ls = "eza --icons --color=always --group-directories-first";
      ll = "eza -la --icons --color=always --group-directories-first";
      lt = "eza --tree --icons --color=always --level 2";
      cat = "bat --style=auto";
      nrs = "sudo nixos-rebuild switch --flake $FLAKE_DIR#desktop";
      nrt = "sudo nixos-rebuild test --flake $FLAKE_DIR#desktop";
      wp = "change-wallpaper";
    };

    interactiveShellInit = ''
      set -g fish_greeting ""

      # any-nix-shell: keep fish when entering nix-shell / nix develop
      ${pkgs.any-nix-shell}/bin/any-nix-shell fish --info-right | source

      # --- Tide prompt layout ---
      set -g tide_left_prompt_items os pwd git
      set -g tide_right_prompt_items status cmd_duration jobs nix_shell
      set -g tide_left_prompt_separator_diff_color ""
      set -g tide_left_prompt_separator_same_color ""
      set -g tide_left_prompt_prefix ""
      set -g tide_left_prompt_suffix " "
      set -g tide_right_prompt_prefix " "
      set -g tide_right_prompt_suffix ""
      set -g tide_prompt_add_newline_before true
      set -g tide_prompt_min_cols 34
      set -g tide_prompt_pad_items false

      # --- Tide item colors — ANSI names so kitty/matugen remapping applies ---
      set -g tide_pwd_color_anchors white
      set -g tide_pwd_color_dirs brblack
      set -g tide_pwd_color_truncated_dirs brblack
      set -g tide_pwd_icon ""
      set -g tide_pwd_truncation_length 3

      set -g tide_git_color_branch magenta
      set -g tide_git_color_conflicted red
      set -g tide_git_color_dirty yellow
      set -g tide_git_color_operation yellow
      set -g tide_git_color_staged green
      set -g tide_git_color_stash cyan
      set -g tide_git_color_untracked brblack
      set -g tide_git_color_upstream brblack
      set -g tide_git_icon " "
      set -g tide_git_truncation_length 24

      set -g tide_cmd_duration_color brblack
      set -g tide_cmd_duration_decimals 0
      set -g tide_cmd_duration_threshold 2000
      set -g tide_cmd_duration_icon ""

      set -g tide_status_color green
      set -g tide_status_color_failure red
      set -g tide_status_icon "✔"
      set -g tide_status_icon_failure "✘"

      set -g tide_nix_shell_color cyan
      set -g tide_nix_shell_icon " "

      set -g tide_jobs_color brblack
      set -g tide_jobs_icon "⚙"

      # --- Fish syntax highlighting — ANSI names for matugen remapping ---
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
