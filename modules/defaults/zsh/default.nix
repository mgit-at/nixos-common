{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    interactiveShellInit = builtins.readFile ./zshrc + ''
      # fixes "no matches found"
      # unsetopt EXTENDED_GLOB
      setopt NO_NOMATCH
    '';
  };

  users.defaultUserShell = pkgs.zsh;
}
