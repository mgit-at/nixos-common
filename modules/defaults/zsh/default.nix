{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    interactiveShellInit = builtins.readFile ./zshrc;
  };

  users.defaultUserShell = pkgs.zsh;
}
