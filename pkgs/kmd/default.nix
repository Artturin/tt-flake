{ pkgs, kernel }:

let
  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-kmd";
    rev = "refs/tags/ttkmd-${version}";
    hash = "sha256-TTd+SXUQ/RwsZB7YIc0QsE9zHBCYO3NRrCub7/K1rP4=";
  };
  version = "1.31";
in
{
  kmd = pkgs.stdenv.mkDerivation {
    pname = "tt-kmd";

    inherit src version;

    nativeBuildInputs = kernel.moduleBuildDependencies;
    hardeningDisable = [ "all" ];
    buildPhase = ''
      make modules -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build M=$(pwd -P)
    '';
    installPhase = ''
      mkdir -p $out/lib/modules/${kernel.modDirVersion}/extra
      cp tenstorrent.ko $out/lib/modules/${kernel.modDirVersion}/extra/
    '';
  };

  udev-rules = pkgs.stdenv.mkDerivation rec {
    pname = "tenstorrent-udev-rules";

    inherit src version;

    dontUnpack = true;

    installPhase = ''
      install -Dpm644 $src/udev-50-tenstorrent.rules $out/lib/udev/rules.d/50-tenstorrent.rules
    '';
  };

  test = pkgs.stdenv.mkDerivation {
    pname = "tt-kmd-test";

    # https://github.com/tenstorrent/tt-kmd/pull/37
    patches = ./limits.patch;

    inherit src version;

    nativeBuildInputs = [ pkgs.gnumake ];

    buildPhase = ''
      make -C test
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp test/ttkmd_test $out/bin/tt-kmd-test
    '';
  };
}
