{ lib
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation rec {
  pname = "ansible-vault-tools";
  version = "unstable-2017-08-25";

  src = fetchFromGitHub {
    owner = "mgit-at";
    repo = "ansible-vault-tools";
    rev = "1a7c7817dd3052b077fb6809e303e46d7b711df1";
    hash = "sha256-XNvjG6Zgo30HJXPz0KWf1Qzm6j/oB7PMLL+WQ+AnMuw=";
  };

  buildPhase = ''
    mkdir -p $out/bin
  '';

  makeFlags = [ "prefix=$(out)" ];

  meta = with lib; {
    description = "Tools for working with ansible-vault";
    homepage = "https://github.com/mgit-at/ansible-vault-tools";
    changelog = "https://github.com/mgit-at/ansible-vault-tools/blob/${src.rev}/CHANGES.md";
    license = licenses.isc;
    maintainers = with maintainers; [ mkg20001 ];
    mainProgram = "ansible-vault-tools";
    platforms = platforms.all;
  };
}
