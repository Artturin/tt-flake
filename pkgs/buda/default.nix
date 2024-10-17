{
  lib,
  python3Packages,
  fetchFromGitHub,
  git,
  cmake,
}:

python3Packages.buildPythonApplication rec {
  pname = "tt-buda";
  version = "0.19.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-buda";
    rev = "v${version}";
    #hash = "sha256-g5eB2roVh4t4fhM+t2QYm+3NXYM94hbwstWES2sL6hA=";
    hash = "sha256-a+yamtu93AypLAXa9cj3yQ1AcizEBbmDd8fa2RNjGcQ=";
    fetchSubmodules = true;
    leaveDotGit = true;
  };

  build-system = [
    python3Packages.setuptools
    python3Packages.wheel
  ];

  nativeBuildInputs = [
    git
    cmake
  ] ++ python3Packages.pybind11.propagatedNativeBuildInputs;

  buildInputs = [
    python3Packages.python # pybind python.h
  ];

  postPatch = ''
    substituteInPlace compile_flags.txt third_party/budabackend/compile_flags.txt \
      --replace-fail "-I/usr/include/python3.8" "-I/usr/include/python3.8"
  '';

  dontUseCmakeConfigure = true;

  pythonImportsCheck = [
    "tt_buda"
  ];

  BACKEND_ARCH_NAME = "wormhole_b0";
  ARCH_NAME = "wormhole_b0";

  meta = {
    description = "Tenstorrent TT-BUDA Repository";
    homepage = "https://github.com/tenstorrent/tt-buda";
    license = lib.licenses.asl20;
    mainProgram = "tt-buda";
  };
}
