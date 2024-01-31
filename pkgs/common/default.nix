{ pkgs }:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tools-common";
  version = "main-2024-01-31";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-tools-common";
    rev = "b23ce52352fdf19bf8cd3e3fcea181aa9d2e7dc9";
    sha256 = "sha256-+BMYCI0+G4zYTI7uyPp+RLyUkKt1fS1WNltnD3xMk2g=";
  };

  patches = [ ./pyproject.patch ];
  
  format = "pyproject";

  propagatedBuildInputs = [ setuptools distro elasticsearch psutil pyyaml rich textual requests ];

  pythonImportsCheck = [
    "tt_tools_common"
  ];
}
