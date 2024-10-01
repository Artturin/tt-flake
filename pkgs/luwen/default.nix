{ pkgs }:

{
  luwen = pkgs.rustPlatform.buildRustPackage rec {
    pname = "luwen";
    version = "main-2024-01-31";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent";
      repo = "luwen";
      rev = "4753a930adb217b296e32f8c682344d929b561bd";
      sha256 = "sha256-UiTVZZt0ZFwZ6wCTpk+8ZLYjtdSiMFklXoh6bDFZXKQ=";
    };

    postPatch = ''
      ln -s ${./Cargo_0_2.lock} Cargo.lock
    '';

    cargoLock.lockFile = ./Cargo_0_2.lock;
    cargoHash = "";
  };

  pyluwen = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "pyluwen";
    version = "main-2024-01-31";

    src = pkgs.fetchFromGitHub {
      owner = "tenstorrent";
      repo = "luwen";
      rev = "4753a930adb217b296e32f8c682344d929b561bd";
      sha256 = "sha256-UiTVZZt0ZFwZ6wCTpk+8ZLYjtdSiMFklXoh6bDFZXKQ=";
    };

    postPatch = ''
      ln -s ${./Cargo_0_2.lock} Cargo.lock
    '';

    buildAndTestSubdir = "crates/pyluwen";

    format = "pyproject";

    cargoDeps = pkgs.rustPlatform.fetchCargoTarball {
      inherit src;
      name = "${pname}-${version}";
      hash = "sha256-7FiLEdgZZgsNXHt81tdP+L6rOA1MqlzGz0SkFWvg10I=";
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
