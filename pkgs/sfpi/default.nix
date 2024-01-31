{ pkgs }:

rec {
  sfpi = pkgs.stdenv.mkDerivation {
    pname = "sfpi";
    version = "master-01-30-24";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent-metal";
      repo = "sfpi";
      rev = "aa4e71d";
      hash = "sha256-JWSEDx7CCAfuhEhrmcrZunEwWdrsXl71pLJA4Fqme0s=";
    };

    postPatch = ''
      ln -s ${tt-gcc} compiler
    '';

    buildPhase = ''
      make -C tests all
    '';

    installPhase = ''
      mkdir -p $out/compiler/libexec
      bin/release.sh $out
    '';
  };

  tt-gcc = import ./tt-gcc.nix { inherit pkgs; };
}
