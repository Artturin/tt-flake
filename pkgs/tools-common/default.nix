{ pkgs }:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tools-common";
  version = "1.4.12";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-tools-common";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-FKV1ojY9m5aRfnrU6LjXVcUnNAmNNXiGaUax6RE/8Vs=";
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
