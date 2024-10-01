{
  pkgs,
  pyluwen,
  tools-common,
}:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tt-smi";
  version = "main-01-31-24";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-smi";
    rev = "2071978";
    hash = "sha256-sqwGWeeMBxOyHiVI2GcQ5CyZ8Zaty7FjhkS0C7H7QkM=";
  };

  format = "pyproject";

  patches = [
    ./pyproject.patch
    ./log.patch
  ];

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
