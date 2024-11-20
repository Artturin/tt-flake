{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  bash,
  coreutils,
  pciutils,
  gawk,
}:

# NOTE: We might not use these files if we end up doing the things it does in nix instead if possible.

stdenv.mkDerivation rec {
  pname = "tt-system-tools";
  version = "unstable-2024-10-11";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-system-tools";
    rev = "29ba4dc6049eef3cee4314c53720417823ffc667";
    hash = "sha256-1Z6I5LAfOdNrTSBm49LyBGkmlhgfXKsAxA867rvDiIE=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ bash ];

  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    install -Dm444 -t $out/lib/systemd/system/ "tenstorrent-hugepages.service"
    install -Dm444 -t $out/lib/systemd/system/ 'dev-hugepages\x2d1G.mount'
    install -Dm555 -t $out/libexec/ "hugepages-setup.sh"

    runHook postInstall
  '';

  postFixup = ''
    substituteInPlace "$out/lib/systemd/system/tenstorrent-hugepages.service" \
      --replace-fail "/opt/tenstorrent/bin/hugepages-setup.sh" "$out/libexec/hugepages-setup.sh"

    mv "$out/libexec/hugepages-setup.sh" "$out/libexec/.hugepages-setup.sh-wrapped"
    makeWrapper ${bash}/bin/bash "$out/libexec/hugepages-setup.sh" \
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          pciutils
          gawk
        ]
      } \
      --add-flags "-x $out/libexec/.hugepages-setup.sh-wrapped"
      # add -x easier debugging
  '';

  meta = {
    homepage = "https://github.com/tenstorrent/tt-system-tools";
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
  };
}
