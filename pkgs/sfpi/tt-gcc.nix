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
    leaveDotGit = false;
    hash = "sha256-+bD4GzQ1bSTDOm4Vqxr70uF6yWuIU1ZgZvuRLQO4Or0=";
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
