{
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  llvmPackages_17,
  cpm-cmake,
  git,
  cacert,
  python3,
  numactl,
  sfpi,
  hwloc,
  libz,

}:

let
  llvmPackages = llvmPackages_17;
  depsDir = "deps";

  version = "unstable-2024-10-04";

  metal-deps = metal.overrideAttrs (previousAttrs: {
    name = "tt-metal-deps-${version}.tar.gz";

    dontBuild = true;

    outputHash = "sha256-UOBBqIP2KKEn2pfv7l5v2Of9RoZY0+3TCEu94MQUVYo=";
    outputHashAlgo = "sha256";

    cmakeFlags = [
      "-DCPM_DOWNLOAD_ALL=ON"
      "-DCPM_SOURCE_CACHE=${depsDir}"
    ];

    # Infinite recursion
    postUnpack = "";

    installPhase = ''
      runHook preInstall

      # Prune the `.git` directories
      find ${depsDir} -name .git -type d -prune -exec rm -rf {} \;;
      # Build a reproducible tar, per instructions at https://reproducible-builds.org/docs/archives/
      tar --owner=0 --group=0 --numeric-owner --format=gnu \
          --sort=name --mtime="@$SOURCE_DATE_EPOCH" \
          -czf $out \
            ${depsDir} \

      runHook postInstall
    '';

  });
  # NOTE: When changing something remember to make sure the outputHash above doesn't change, or if it changes then update it.
  metal = llvmPackages.libcxxStdenv.mkDerivation {
    pname = "tt-metal";
    inherit version;
    src = fetchFromGitHub {
      owner = "tenstorrent";
      repo = "tt-metal";
      rev = "0fb4249a94a99714de8f91d93d338832694c09e0";
      # this takes a while and we don't need all of them
      fetchSubmodules = true;
      hash = "sha256-0tcIwaJzM75S7SFKCJ2UbfElwASpFwdySmzt2LUTT4A=";
    };

    env.NIX_CFLAGS_COMPILE = "-Wno-unused-command-line-argument";

    nativeBuildInputs = [
      cmake
      ninja
      python3
      # for cpm
      git
      cacert
    ];

    buildInputs = [
      numactl

      # umd
      hwloc
      libz

    ];

    postUnpack = ''
      mkdir -p $sourceRoot/build
      tar -xf ${metal-deps} -C $sourceRoot/build
    '';

    postPatch = ''
      cp ${cpm-cmake}/share/cpm/CPM.cmake cmake/CPM.cmake
      rm -rf tt_metal/third_party/sfpi/compiler
      ln -s ${sfpi.tt-gcc} tt_metal/third_party/sfpi/compiler
    '';

    preConfigure = ''
      export ARCH_NAME=wormhole_b0
      export TT_METAL_HOME=$(pwd)
      export PYTHONPATH=$(pwd)
    '';

    cmakeFlags = [
      "-DCPM_SOURCE_CACHE=${depsDir}"
    ];

    postInstall = ''
      pwd
      mkdir -p $out/lib
      cp lib/{_ttnn.so,libtt_metal.so} $out/lib
    '';

    passthru = {
      inherit metal-deps;
    };

  };
in
metal
