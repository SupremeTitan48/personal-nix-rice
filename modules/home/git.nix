# modules/home/git.nix
{ pkgs, config, ... }:
{
  programs.git = {
    enable = true;
    userName = "Jackson Koch";
    userEmail = "jacksongkoch@icloud.com";

    delta = {
      enable = true;
      options = {
        navigate = true;
        light = false;
        side-by-side = true;
      };
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      lg = "log --oneline --graph --decorate --all";
      undo = "reset HEAD~1 --mixed";
    };

    extraConfig = {
      push.autoSetupRemote = true;
      pull.rebase = true;
      init.defaultBranch = "main";
      core.autocrlf = "input";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };

    ignores = [ ".direnv" ".envrc" "*.swp" ".DS_Store" "result" "result-*" ];
  };

  programs.ssh = {
    enable = true;
    addKeysToAgent = "yes";
    controlMaster = "auto";
    controlPath = "~/.ssh/cm-%r@%h:%p";
    controlPersist = "10m";
    serverAliveInterval = 60;
    serverAliveCountMax = 3;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.gpg.enable = true;

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    enableSshSupport = false;
    defaultCacheTtl = 3600;
    maxCacheTtl = 86400;
  };
}
