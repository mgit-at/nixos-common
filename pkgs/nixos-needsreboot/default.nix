{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "nixos-needsreboot";
  version = "unstable-2024-03-06";

  src = fetchFromGitHub {
    owner = "srounce";
    repo = "nixos-needsreboot";
    rev = "9089c7343fc6fe4bb2f899e85686a77e64b33cd6";
    hash = "sha256-ACaUD16GQQeDYb5JXBE56JjV7bidztPFsZpaSLrFP/U=";
  };

  cargoHash = "sha256-Zf+tL6i7QDChJIpNAfVp6awYtMOvNwpYZZvp3exJRFk=";

  meta = with lib; {
    description = "Determine if you need to reboot your NixOS machine";
    homepage = "https://github.com/srounce/nixos-needsreboot";
    license = licenses.free; # FIXME: nix-init did not found a license
    maintainers = with maintainers; [ mkg20001 ];
    mainProgram = "nixos-needsreboot";
  };
}
