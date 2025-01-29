{ pkgs }:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tools-common";
  # https://github.com/tenstorrent/tt-smi/blob/main/pyproject.toml#L31
  version = "1.4.11";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-tools-common";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-Q5GpT6B3pamY6bUjPbvNJ11npiR4q/6QMjRxovQ/MZ0=";
  };

  format = "pyproject";

  nativeBuildInputs = [ pythonRelaxDepsHook ];

  pythonRelaxDeps = [
    "distro"
    "elasticsearch"
    "psutil"
    "pyyaml"
    "rich"
    "requests"
    "textual"
    "tqdm"
  ];

  propagatedBuildInputs = [
    setuptools
    distro
    elasticsearch
    psutil
    pyyaml
    rich
    textual
    requests
    jsons
    tqdm
    pydantic
  ];

  pythonImportsCheck = [
    "tt_tools_common"
  ];
}
