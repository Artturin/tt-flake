{ pkgs }:

let
  depsDir = "deps";

  version = "unstable-2024-10-01";

  # Update outputHash in umd-deps too
  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-umd";
    rev = "5293e508ade90e758b386068770a882667a535f0";
    hash = "sha256-Pa6vFjsG30UnGwLKZc/OTmiSMkXs/0sAFwVGojE8IbY=";
  };

  umd-deps = tt-umd.overrideAttrs (previousAttrs: {
    name = "tt-umd-deps-${version}.tar.gz";

    inherit src;

    dontBuild = true;

    outputHash = "sha256-/T7UJ1OCd4T68DXOxHjGLYiiLoEZIRt7PHbT9npT4uk=";
    outputHashAlgo = "sha256";

    cmakeFlags = [
      "-DCPM_DOWNLOAD_ALL=ON"
      "-DCPM_SOURCE_CACHE=${depsDir}"
      "-DTT_UMD_BUILD_TESTS=ON"
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

  tt-umd = pkgs.stdenv.mkDerivation {
    pname = "tt-umd";
    inherit version src;

    nativeBuildInputs = with pkgs; [
      cmake
      git
      cacert
      ninja
      python3
      removeReferencesTo
    ];

    buildInputs = with pkgs; [
      libyamlcpp
      boost
      fmt
      hwloc
    ];

    ARCH_NAME = "wormhole_b0";
    cmakeFlags = [
      "-DCPM_SOURCE_CACHE=${depsDir}"
      # libdevice.so
      # RUNPATH              /build/source/build/_deps/nanomsg-build:/build/source/build/_deps/libuv-build:/nix/store/n1yy5f1754p2d6dhksvg6rwpayymw1fx-tt-umd-unstable-2024-10-01/lib/:...
      # TODO: look in to fixing properly if there's a need.
      "-DCMAKE_SKIP_BUILD_RPATH=ON"
    ];

    postUnpack = ''
      mkdir -p $sourceRoot/build
      tar -xf ${umd-deps} -C $sourceRoot/build
    '';

    postPatch = ''
      cp ${pkgs.cpm-cmake}/share/cpm/CPM.cmake cmake/CPM.cmake
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      mv lib/libdevice.so $out/lib
      runHook postInstall
    '';
  };

in

tt-umd
