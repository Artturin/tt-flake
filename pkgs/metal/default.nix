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
  runCommand,
  libexecinfo,
  callPackage,
}:

let
  llvmPackages = llvmPackages_17;
  depsDir = "deps";

  version = "0.53.0";

  metal-deps = metal.overrideAttrs (previousAttrs: {
    name = "tt-metal-deps-${version}.tar.gz";

    dontBuild = true;

    outputHash = "sha256-hhLjEssXID+uiPQ3kexMCOVB6DB9m/eAVmfr2OleGXc=";
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

  # NOTE: When changing something remember to make sure the outputHash above doesn't change, or if it changes then update it.
  metal = llvmPackages.libcxxStdenv.mkDerivation {
    pname = "tt-metal";
    inherit version;
    src = fetchFromGitHub {
      owner = "tenstorrent";
      repo = "tt-metal";
      rev = "154e6993aed78213446c59731e41c3617d83c1f1";
      hash = "sha256-edtlE4CVsTO4BW0PKhkN0IxdV666Tu/Y1jgZ2Exljeo=";
      fetchSubmodules = true;
      fetchLFS = true;
    };

    patches = [
      ./rpath.patch
    ];

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

      substituteInPlace tt_metal/CMakeLists.txt ttnn/CMakeLists.txt \
        --replace-fail "REPLACETHIS\"" "$out/lib\"" \
        --replace-warn "REPLACETHIS1" "$out/build/lib"

      substituteInPlace tt_metal/hw/CMakeLists.txt \
        --replace-fail "FetchContent_MakeAvailable(sfpi)" ""
      mkdir -p runtime
      ln -s ${sfpi.prebuilt} runtime/sfpi
    '';

    ARCH_NAME = "wormhole_b0";

    preConfigure = ''
      export TT_METAL_HOME=$(pwd)
      export PYTHONPATH=$(pwd)
    '';

    cmakeFlags = [
      "-DCPM_SOURCE_CACHE=${depsDir}"
    ];

    postInstall = ''
      # Have to do this until cpp-ttnn-project-template is fixed
      # ttnn-template> ninja: error: '/nix/store/-tt-metal-unstable-2024-10-04/build/lib/_ttnn.so', needed by 'sources/examples/sample_app/sample_app', missing and no known rule to make it
      cp -r ../ $out
      rm -rf $out/.cpmcache
      ln -s $out/build/deps $out/.cpmcache

      # Nix checks for references to /build/source so these should be different but not a different size to prevent corruption
      find "$out" -type f -print0 | while IFS= read -r -d $'\0' f; do
        sed -i "s|/build/source|/suild/source|g" "$f"
        sed -i 's|$ORIGIN/build/lib:|$ORIGIN/suild/lib:|g' "$f"
      done
    '';

    dontPatchELF = true;
    dontStrip = true;

    passthru = {
      inherit metal-deps;
      tests = {
        template = callPackage ./ttnn-template.nix { inherit metal; };
      };
    };

  };
in
metal
