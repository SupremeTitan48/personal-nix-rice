# modules/home/terminal.nix
{ config, pkgs, lib, ... }:
let
  # Colors tuned to complement the matugen dark base (#0d0f14)
  # Using 256-color codes so they degrade gracefully before first matugen run
  c = {
    fg        = "D0D0E0";  # cool near-white
    muted     = "7070A0";  # muted blue-grey
    accent    = "9580FF";  # soft purple accent (matugen may override via kitty theme)
    green     = "69FF94";
    yellow    = "FFD580";
    orange    = "FF9580";
    red       = "FF6E6E";
    cyan      = "80FFEA";
  };
in
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

    plugins = [
      { name = "tide"; src = pkgs.fishPlugins.tide.src; }
    ];

    interactiveShellInit = ''
      set -g fish_greeting ""

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

      # --- Tide item colors (complement matugen dark base) ---
      set -g tide_pwd_color_anchors ${c.fg}
      set -g tide_pwd_color_dirs ${c.muted}
      set -g tide_pwd_color_truncated_dirs ${c.muted}
      set -g tide_pwd_icon ""
      set -g tide_pwd_truncation_length 3

      set -g tide_git_color_branch ${c.accent}
      set -g tide_git_color_conflicted ${c.red}
      set -g tide_git_color_dirty ${c.yellow}
      set -g tide_git_color_operation ${c.orange}
      set -g tide_git_color_staged ${c.green}
      set -g tide_git_color_stash ${c.cyan}
      set -g tide_git_color_untracked ${c.muted}
      set -g tide_git_color_upstream ${c.muted}
      set -g tide_git_icon " "
      set -g tide_git_truncation_length 24

      set -g tide_cmd_duration_color ${c.muted}
      set -g tide_cmd_duration_decimals 0
      set -g tide_cmd_duration_threshold 2000
      set -g tide_cmd_duration_icon ""

      set -g tide_status_color ${c.green}
      set -g tide_status_color_failure ${c.red}
      set -g tide_status_icon "✔"
      set -g tide_status_icon_failure "✘"

      set -g tide_nix_shell_color ${c.cyan}
      set -g tide_nix_shell_icon " "

      set -g tide_jobs_color ${c.muted}
      set -g tide_jobs_icon "⚙"

      # --- Fish syntax highlighting ---
      set -g fish_color_command ${c.accent}
      set -g fish_color_param ${c.fg}
      set -g fish_color_keyword ${c.orange}
      set -g fish_color_quote ${c.green}
      set -g fish_color_redirection ${c.cyan}
      set -g fish_color_end ${c.muted}
      set -g fish_color_error ${c.red}
      set -g fish_color_comment ${c.muted}
      set -g fish_color_autosuggestion ${c.muted}
      set -g fish_color_operator ${c.yellow}
      set -g fish_color_escape ${c.orange}
      set -g fish_color_selection --background=${c.muted}
      set -g fish_pager_color_selected_background --background=${c.muted}

      # --- Aliases ---
      alias ls 'eza --icons --color=always --group-directories-first'
      alias ll 'eza -la --icons --color=always --group-directories-first'
      alias lt 'eza --tree --icons --color=always --level 2'
      alias cat 'bat --style=auto'
      alias nrs 'sudo nixos-rebuild switch --flake ~/personal-nix-rice#desktop'
      alias nrt 'sudo nixos-rebuild test --flake ~/personal-nix-rice#desktop'
      alias wp 'change-wallpaper'
    '';
  };

  home.packages = with pkgs; [
    eza
    bat
    playerctl
  ];
}
