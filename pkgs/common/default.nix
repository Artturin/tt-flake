{ pkgs }:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tools-common";
  version = "unstable-2024-09-27";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-tools-common";
    rev = "a89b2db6d086698ab0351a820ea689b4809429a3";
    sha256 = "sha256-xeiJQkWsg9p8re2XJai0mNWuP7LwJ9faj3+Z3U/KvzI=";
  };

  format = "pyproject";

  nativeBuildInputs = [ pythonRelaxDepsHook ];

  pythonRelaxDeps = [ "distro" "elasticsearch" "psutil" "pyyaml" "rich" "requests" "textual" "tqdm" ];

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
