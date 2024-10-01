{
  pkgs,
  pyluwen,
  tools-common,
}:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tt-smi";
  version = "unstable-2024-09-27";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-smi";
    rev = "052f1ce49b94581710744a91939121e01c24b5f2";
    hash = "sha256-IA60unZpSWVnMnDjDIC31QtURi9nIr/F7s7PGZilPcw=";
  };

  format = "pyproject";

  patches = [
    # TODO: Still needed? Builds without.
    #./log.patch
  ];

  nativeBuildInputs = [ pythonRelaxDepsHook ];

  pythonRelaxDeps = [ "black" "distro" "elasticsearch" "rich" "textual" "pre-commit" "importlib-resources" ];

  propagatedBuildInputs = [
    setuptools
    requests
    textual
    black
    distro
    elasticsearch
    jsons
    pydantic
    psutil
    pyyaml
    pyluwen
    importlib-resources
    pkgs.pre-commit
    tools-common
  ];
}
