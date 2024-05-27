{ pkgs, ... }:

let
  empty = pkgs.writeTextDir "empty" "";
  createEmptyProfile = ''
    if [ ! -e "$HOME/.nix-profile/manifest.json" ]; then
      (nix profile install ${empty} && nix profile remove ${empty}) >/dev/null 2>/dev/null || true
    fi
  '';
in {
  programs.zsh.interactiveShellInit = createEmptyProfile;
  programs.bash.interactiveShellInit = createEmptyProfile;
}
