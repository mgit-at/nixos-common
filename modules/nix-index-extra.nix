let
  createEmptyProfile = ''
    if [ ! -e "$HOME/.nix-profile/manifest.json" ]; then
      nix profile upgrade >/dev/null 2>/dev/null || true
    fi
  '';
in {
  programs.zsh.interactiveShellInit = createEmptyProfile;
  programs.bash.interactiveShellInit = createEmptyProfile;
}
