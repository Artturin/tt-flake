{ pkgs }:

rec {
  sfpi = pkgs.stdenv.mkDerivation {
    pname = "sfpi";
    version = "unstable-2024-10-10";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent-metal";
      repo = "sfpi";
      rev = "899b8b6c90fc3e18ad081fd556eaa1a473c8a357";
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

    passthru = { inherit sfpi-no-lfs; };
  };


  sfpi-no-lfs = pkgs.stdenv.mkDerivation {
    pname = "sfpi";
    version = "unstable-2024-11-15";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent-metal";
      repo = "sfpi";
      rev = "fcb552bc66d274fc4ffadc35eb4e6d1f20b2e6b3";
      hash = "";
      fetchSubmodules = true;
    };

    postPatch = ''
      patchShebangs --build $scripts/build.sh
    '';

    buildPhase = ''
      ./scripts/build.sh
    '';

    installPhase = ''
      mkdir -p "$out"
      cp -r ./sfpi/* "$out"
    '';

  };

  tt-gcc = import ./tt-gcc.nix { inherit pkgs; };
}
