{
  lib,
  python310Packages,
  fetchzip,
  stdenv,
  callPackage,
  __splicedPackages,
  darwin,
  runCommand,
}:

let
  python3Packages = python310Packages;
  pkgs = __splicedPackages;

  boost_1_74 = (callPackage ./vendored/boost/default.nix { }).boost174;
  yaml-cpp_0_6 = callPackage ./vendored/libyaml-cpp.nix { };

  prebuilt-buda = fetchzip {
    url = "https://github.com/tenstorrent/tt-buda/releases/download/v0.19.3/pybuda-wh.b0-v0.19.3-ubuntu-22-04-amd64-python3.10.zip";
    hash = "sha256-M9sgFKSmWra+BglEWgrfFPJRS+UIVKUG+ZF1oTPVexg=";
    stripRoot = false;
  };

  pipInstallHook' = python3Packages.callPackage (
    { makePythonHook, pip }:
    makePythonHook {
      name = "pip-install-hook";
      propagatedBuildInputs = [ pip ];
      substitutions = {
        pythonInterpreter = python3Packages.python.interpreter;
        pythonSitePackages = python3Packages.python.sitePackages;
      };
    } ./vendored/pip-install-hook.sh
  ) { };

  nukeReferences = callPackage ./vendored/nuke-references.nix {
    inherit (darwin) signingUtils;
  };

  autoPatchelfHook = callPackage (
    { makeSetupHook, bintools }:
    makeSetupHook {
      name = "auto-patchelf-hook";
      propagatedBuildInputs = [
        bintools
      ];
      substitutions = {
        pythonInterpreter = "${python3Packages.python.withPackages (ps: [ ps.pyelftools ])}/bin/python";
        autoPatchelfScript = ./vendored/auto-patchelf.py;
      };
    } ./auto-patchelf.sh
  ) { };

  tt-buda = stdenv.mkDerivation rec {
    pname = "tt-buda";
    version = "0.19.3";
    format = "wheel";

    src = prebuilt-buda;

    nativeBuildInputs = [
      pipInstallHook'
      nukeReferences
    ];

    preInstall = ''
      mkdir dist
      mv *.whl dist/
    '';

    postInstall = ''
      find $out -name "__pycache__" -type d | xargs rm -rf

      find $out/bin/ -type f -not -name 'debuda' -print0 | xargs -0 rm --
      substituteInPlace $out/bin/debuda \
        --replace-fail "${python3Packages.python.interpreter}" "/usr/bin/env python3"

      # error: illegal path references in fixed-output derivation
      find $out -print0 | xargs -0 nuke-refs

    '';

    dontPatchShebangs = true;
    dontFixup = true;

    outputHash = "sha256-eSU10kgIQzJ0kv6gmQwMCdVw0uBpohVyYqkjK4RU2ng=";
    outputHashAlgo = "sha256";
    outputHashMode = "recursive";

    meta = {
      description = "Tenstorrent TT-BUDA Repository";
      homepage = "https://github.com/tenstorrent/tt-buda";
      license = lib.licenses.asl20;
      mainProgram = "tt-buda";
    };
  };

  tt-buda-final = python3Packages.toPythonModule (
    stdenv.mkDerivation (finalAttrs: {
      pname = "tt-buda-final";
      inherit (tt-buda) version;

      nativeBuildInputs = [
        autoPatchelfHook
        python3Packages.pythonImportsCheckHook
      ];

      buildInputs =
        with pkgs;
        [
          stdenv.cc.libc.libgcc
          stdenv.cc.libc.libgcc.lib
          libpng
          python3Packages.python
          ncurses
          expat
          hwloc
          zeromq
          libjpeg8
          glib
          libGL
          boost_1_74
          yaml-cpp_0_6
        ]
        ++ (with pkgs.xorg; [
          libxcb
          libXext
          libX11
          libSM
          libICE
        ]);

      #runtimeDependencies = [
      #  # from torch._C import *  # noqa: F403
      #  # ImportError: libstdc++.so.6: cannot open shared object file: No such file or directory
      #  stdenv.cc.libc.libgcc.lib

      #];

      #pythonImportsCheck = [
      #  "pybuda"
      #  "torch"
      #];

      passthru = {
        inherit tt-buda yaml-cpp_0_6 boost_1_74;
        pythonWith = python3Packages.python.withPackages (ps: [ finalAttrs.finalPackage ]);

        tests = {
          integrationTest =
            runCommand "tt-buda-tests-integration-test"
              {
                strictDeps = true;
                nativeBuildInputs = [
                  finalAttrs.passthru.pythonWith
                  stdenv.cc.libc.libgcc.lib
                ];
                LD_LIBRARY_PATH = lib.makeLibraryPath [ stdenv.cc.libc.libgcc.lib ];
              }
              ''
                export HOME=$(mktemp -d)
                python3 "${./test.py}"
                touch "$out"
              '';
        };
      };

      dontUnpack = true;
      installPhase = ''
        runHook preInstall
        mkdir -p $out
        cp -r ${tt-buda}/* $out
        runHook postInstall


      '';
    })
  );
in
tt-buda-final
