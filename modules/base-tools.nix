{ pkgs, ... }:

{
  programs.mtr.enable = true;

  environment.systemPackages = with pkgs; [
    htop
    curl
    dstat
    lsof
    ethtool
    gawk
    psmisc
    less
    vim # vim-tiny
    # screen (see defaults/screen.nix)
    # mtr-tiny (see enable above)
    tcpdump
    unp
    # aptitude (not useful on nixos)
    # ncurses-term (not needed)
    # man-db (installed by default)
    # manpages (installed by default)
    netcat-openbsd
    dnsutils
    ioping
    # linux-perf ??
    # linux-cpupower ??
    rng-tools
    acl
    ripgrep
    fd
    # added in nixos
    sysz
    iftop
    cert-viewer
    dua
    (writeShellScriptBin "ncdu" "echo 'did you mean: dua?' && exit 2")
  ];
}
