{ pkgs }:

rec {
  sfpi = pkgs.stdenv.mkDerivation {
    pname = "sfpi";
    version = "unstable-2024-09-25";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent-metal";
      repo = "sfpi";
      # One commit before they started to use gcc 12
      rev = "08d39202f283ab9122e162bcead5b7c90014fa86";
      hash = "sha256-EZHUhAqn9/r02IC+TVoxfIyzEctYQKd5azcrXE5DIgg=";
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
