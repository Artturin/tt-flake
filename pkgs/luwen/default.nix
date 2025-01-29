{ pkgs }:

let

  # Upstream does not vendor a lock file so one has to created manually
  # `cargo generate-lockfile`
  # Use verson needed by tt-smi
  # https://github.com/tenstorrent/tt-smi/blob/main/pyproject.toml#L30
  version = "0.4.9";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "luwen";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-K68PjccE2fBkU4RvKv8X6jKRPYqsVhKB6jU92aajLgo=";
  };

in

{
  luwen = pkgs.rustPlatform.buildRustPackage rec {
    pname = "luwen";
    inherit version src;

    postPatch = ''
      ln -s ${./Cargo_0_2.lock} Cargo.lock
    '';

    cargoLock.lockFile = ./Cargo_0_2.lock;
    cargoHash = "";
  };

  pyluwen = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "pyluwen";
    inherit version src;

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
}
