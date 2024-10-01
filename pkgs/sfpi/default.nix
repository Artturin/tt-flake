{ pkgs }:

rec {
  sfpi = pkgs.stdenv.mkDerivation {
    pname = "sfpi";
    version = "unstable-2024-08-27";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent-metal";
      repo = "sfpi";
      # One commit before they started to use gcc 12
      rev = "0bc7ecf45c6fe374371cf5a3b384df1eaf7ad5b7";
      hash = "sha256-DHyD8eR0yYWHhnEtrMoax/Eoi/N4GhIUn4q0hwzQoR0=";
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
