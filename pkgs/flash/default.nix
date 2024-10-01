{
  pkgs,
  pyluwen,
  tools-common,
}:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tt-flash";
  version = "unstable-2024-09-27";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-flash";
    rev = "4002fee1da7edfcbf09093ba23612caeca071f23";
    hash = "sha256-O6b/vS/zCjp/mrNzFEylWs0jtwdHY65nwkvn5GFridI=";
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
