{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "tt-umd";
  version = "main-2024-02-01";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent-metal";
    repo = "umd";
    rev = "341f5b7b299f128faaf2ca446a03298cb781a645";
    hash = "sha256-jMxhhFWnCjNZZvFiTCeuEHvxvE0+IoaP4NJkr/CDLy8=";
  };

  patches = [ ./fmt_mystery.patch ./missing_headers.patch ];

  makeFlags = [
    "DEVICE_CXX=${pkgs.stdenv.cc.targetPrefix}c++"
    "ARCH_NAME=grayskull"
  ];

  buildInputs = with pkgs; [ libyamlcpp boost fmt hwloc ];

  installPhase = ''
    mkdir $out
    mv build/lib $out
  '';
}
