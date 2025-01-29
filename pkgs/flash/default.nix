{
  pkgs,
  pyluwen,
  tools-common,
}:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tt-flash";
  version = "3.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-flash";
    rev = "refs/tags/v${version}";
    hash = "sha256-t2B1XEOKBKxE2eQiS7pc+EemBWomMgocyk4oRDt0Q78=";
  };

  nativeBuildInputs = [ pythonRelaxDepsHook ];

  pythonRelaxDeps = [
    "pyyaml"
  ];

  format = "pyproject";

  # patches = [ ./pyproject.patch ./log.patch ];

  propagatedBuildInputs = [
    setuptools
    pyyaml
    pyluwen
    tabulate
    tools-common
  ]; # requests textual black distro elasticsearch jsons pydantic psutil pyyaml pyluwen importlib-resources pkgs.pre-commit tools-common ];
}
