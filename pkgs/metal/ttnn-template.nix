{
  stdenv,
  fetchFromGitHub,
  metal,
  cmake,
  ninja,
  git,
  cacert,
  python3,
  numactl,
  hwloc,
  libz,
  llvmPackages_17,
  cpm-cmake,
  sfpi,

}:

let
  version = "0";
  llvmPackages = llvmPackages_17;
  depsDir = "deps";

  ttnn-template-deps = ttnn-template.overrideAttrs (previousAttrs: {
    name = "ttnn-template-deps-deps-${version}.tar.gz";

    dontBuild = true;

    outputHash = "sha256-qt3PLKE3lwqiYQq6m06V1xk1qDOyHAtGj8lw0Q99qgE=";
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

    postInstall = "";
  });

  ttnn-template = llvmPackages.libcxxStdenv.mkDerivation {
    pname = "ttnn-template";
    version = "0";
    src = fetchFromGitHub {
      owner = "tenstorrent";
      repo = "cpp-ttnn-project-template";
      rev = "702b453aa7000daa56692b7559ec77adf407828d";
      hash = "sha256-NzcZCVujJCyHQgALAewJjoWj+6bQXncONO7nRK8zSx4=";
    };

    nativeBuildInputs = [
      cmake
      #ninja
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

    ARCH_NAME = "wormhole_b0";
    TT_METAL_HOME = metal;

    postUnpack = ''
      mkdir -p $sourceRoot/build
      tar -xf ${ttnn-template-deps} -C $sourceRoot/build
    '';

    postPatch = ''
      cp ${cpm-cmake}/share/cpm/CPM.cmake cmake/CPM.cmake

      # Upstream changed these locations and removed libfmt but the template hasn't been updated yet
      # https://github.com/tenstorrent/tt-metal/pull/13788
      substituteInPlace sources/sample_lib/CMakeLists.txt \
        --replace-fail '$ENV{TT_METAL_HOME}/build/lib/_ttnn.so' '${metal}/lib/_ttnn.so' \
        --replace-fail '$ENV{TT_METAL_HOME}/build/lib/libdevice.so' '${metal}/lib/libdevice.so' \
        --replace-fail '$ENV{TT_METAL_HOME}/build/lib/libfmt.so' "" \
        --replace-fail '$ENV{TT_METAL_HOME}/build/lib/libnng.so.1' '${metal}/lib/libnng.so.1.8.0' \

      substituteInPlace sources/sample_lib/CMakeLists.txt \
        --replace-fail '$ENV{TT_METAL_HOME}/build/lib' '${metal}/lib ${metal}/build/lib'
    '';

    # No default install target
    installPhase = ''
      runHook preInstall
      pwd
      install -D sources/examples/sample_app/sample_app $out/bin/sample_app
      runHook postInstall
    '';

    cmakeFlags = [
      "-DCPM_SOURCE_CACHE=${depsDir}"
    ];
  };
in
ttnn-template
