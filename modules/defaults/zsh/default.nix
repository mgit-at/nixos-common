{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    interactiveShellInit = builtins.readFile ./zshrc + ''
      # fixes "no matches found"
      unsetopt EXTENDED_GLOB
    '';
  };

  users.defaultUserShell = pkgs.zsh;
}
