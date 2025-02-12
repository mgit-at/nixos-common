{ pkgs, ... }:

{
  programs.mtr.enable = true;

  programs.htop = {
    enable = true;
    settings = {
      hide_userland_threads = true;
    };
  };

  environment.systemPackages = with pkgs; [
    curl
    dool # dstat has been deprecated, use dool instead
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
    sysz # fzf but for systemctl
    iftop # bandwidth
    cert-viewer
    dua # disk usage analyzer
    (writeShellScriptBin "ncdu" "echo 'did you mean: dua?' && echo '$ dua -x i /' && exit 2")
    pwru # kernel packet processing debugging (tcpdump but for firewall)
    jq
    comma
  ];
}
