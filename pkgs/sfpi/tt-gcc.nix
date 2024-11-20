{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "tt-gcc";
  version = "unstable-2024-09-25";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent-metal";
    repo = "sfpi-tt-gcc";
    # https://github.com/tenstorrent/sfpi-tt-gcc/commits/tt-rel/gcc-12.2
    rev = "a5c31334942e9df66427837f7268269311fdfc2e";
    # this takes a while and we don't need all of them
    fetchSubmodules = true;
    hash = "sha256-1d77+6Yv3i4M7J+vUwcUuFg56wCG9oVeDt+fvBKtHPI=";
  };

  nativeBuildInputs = with pkgs; [
    python3
    util-linux
    git
    cacert
    autoconf
    automake
    curl
    gawk
    bison
    flex
    texinfo
    gperf
    bc
  ];

  buildInputs = with pkgs; [
    libmpc
    mpfr
    gmp
    zlib
    expat
  ];

  configureFlags = [
    "-disable-multilib"
    "-with-abi=ilp32"
    "-with-arch=rv32i"
    "--prefix=${placeholder "out"}"
  ];

  postPatch = ''
    substituteInPlace Makefile.in \
      --replace-fail 'flock `git' 'true'
  '';

  hardeningDisable = [
    "format"
  ];

  enableParallelBuilding = true;
}
