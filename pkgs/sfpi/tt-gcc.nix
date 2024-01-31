{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "tt-gcc";
  version = "master-01-30-24";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent-metal";
    repo = "sfpi-tt-gcc";
    rev = "94a51a7";
    # this takes a while and we don't need all of them
    fetchSubmodules = true;
    leaveDotGit = true;
    hash = "sha256-VliX4Npw8FqTq3vmdsDFRThXFfDgaTomJ+egCEyhOyU=";
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

  hardeningDisable = [
    "format"
  ];

  enableParallelBuilding = true;

  # this is an absolute travesty, but i'm not about to
  # properly repackage all of riscv-gnu-toolchain
  __noChroot = true;
}
