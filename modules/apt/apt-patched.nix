{
  apt,
  dpkg,
}:

apt.overrideAttrs {
  postInstall = ''
    ln -s ${dpkg}/bin/dpkg $out/bin/dpkg

    mv $out/etc/apt/ $out/ETC_APT_TEMPLATE
    mv $out/var/lib/apt $out/VAR_LIB_APT_TEMPLATE
    mv $out/var/cache/apt $out/VAR_CACHE_APT_TEMPLATE
    mv $out/var/log/apt $out/VAR_LOG_APT_TEMPLATE

    for f in /etc/apt /var/lib/apt /var/cache/apt /var/log/apt /var/lib/dpkg; do
      ln -s $f $out$f
    done
  '';
}
