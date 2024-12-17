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

  prebuilt = pkgs.stdenv.mkDerivation rec {
    pname = "tt-gcc";
    version = "5.0.0";

    src = pkgs.fetchzip {
      url = "https://github.com/tenstorrent/sfpi/releases/download/v5.0.0/sfpi-release.tgz";
      hash = "sha256-RBhJ6BWmvB06zWoELTumpzroHDMpNXU0/WC6elgAkW0=";
    };

    nativeBuildInputs = with pkgs; [
      autoPatchelfHook
    ];

    buildInputs = with pkgs; [
      libmpc
      mpfr
      gmp
      zlib
      expat
    ];

    installPhase = ''
      cp -r . $out
    '';

  };

  tt-gcc = import ./tt-gcc.nix { inherit pkgs; };
}
