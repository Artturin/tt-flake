{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "tt-gcc";
  version = "unstable-2024-08-27";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent-metal";
    repo = "sfpi-tt-gcc";
    rev = "c0ed5d7f6f9d7aa24d848a0dc792cc32ca1c9215";
    # this takes a while and we don't need all of them
    fetchSubmodules = true;
    hash = "sha256-mtq/n1g7hfyjLxVK/VYlYRUrdpbp/gJYrFbqwakWkTI=";
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
