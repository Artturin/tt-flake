{
  pkgs,
  pyluwen,
  tools-common,
}:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tt-smi";
  version = "3.0.5";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-smi";
    rev = "refs/tags/v${version}";
    hash = "sha256-+Dw6F9aupe4VTWQFiNWGKMDOTmxwCW2bHuDQxWxluUc=";
  };

  format = "pyproject";

  patches = [
    # TODO: Still needed? Builds without.
    #./log.patch
  ];

  nativeBuildInputs = [ pythonRelaxDepsHook ];

  pythonRelaxDeps = [
    "black"
    "distro"
    "elasticsearch"
    "rich"
    "textual"
    "pre-commit"
    "importlib-resources"
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

  dontUsePytestCheck = true; # no tests

  installCheckPhase = ''
    output=$($out/bin/tt-smi || true)
    echo "tt-smi output: $output"
    echo $output | grep -q "No Tenstorrent driver detected"
  '';
}
