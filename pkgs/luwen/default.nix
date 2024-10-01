{ pkgs }:

{
  luwen = pkgs.rustPlatform.buildRustPackage rec {
    pname = "luwen";
    version = "unstable-2024-09-13";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent";
      repo = "luwen";
      rev = "e4e10e95928f4b73d31ac4f41ea08cd6e3ef5573";
      sha256 = "sha256-cScaqWAyjDuvy9M2EccMfUHfDq23IWniaKeq+upHzOg=";
    };

    postPatch = ''
      ln -s ${./Cargo_0_2.lock} Cargo.lock
    '';

    cargoLock.lockFile = ./Cargo_0_2.lock;
    cargoHash = "";
  };

  pyluwen = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "pyluwen";
    version = "unstable-2024-09-13";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent";
      repo = "luwen";
      rev = "e4e10e95928f4b73d31ac4f41ea08cd6e3ef5573";
      sha256 = "sha256-cScaqWAyjDuvy9M2EccMfUHfDq23IWniaKeq+upHzOg=";
    };

    postPatch = ''
      ln -s ${./Cargo_0_2.lock} Cargo.lock
    '';

    buildAndTestSubdir = "crates/pyluwen";

    format = "pyproject";

    cargoDeps = pkgs.rustPlatform.importCargoLock {
      lockFile = ./Cargo_0_2.lock;
    };

    nativeBuildInputs = [
      pkgs.rustPlatform.cargoSetupHook
      pkgs.rustPlatform.maturinBuildHook
    ];

    pythonImportsCheck = [
      "pyluwen"
    ];
  };

  pyluwen_0_1 = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "pyluwen";
    version = "v0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent";
      repo = "luwen";
      rev = "${version}";
      sha256 = "sha256-MyOzm3dfEkL7MsVzV51DaO+Op3+QhUzsYCTDsvYsvpk=";
    };

    postPatch = ''
      ln -s ${./Cargo_0_1.lock} Cargo.lock
    '';

    buildAndTestSubdir = "crates/pyluwen";

    format = "pyproject";

    cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
      inherit src postPatch;
      name = "${pname}-${version}";
      hash = "sha256-ZXcj/pzQ/tAROdmi2w+AWYBvLSEZFayizxw+BmNDj70=";
    };

    nativeBuildInputs = [
      pkgs.rustPlatform.cargoSetupHook
      pkgs.rustPlatform.maturinBuildHook
    ];

    pythonImportsCheck = [
      "pyluwen"
    ];
  };
}
