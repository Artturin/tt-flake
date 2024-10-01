{ pkgs, pyluwen }:

with pkgs.python3Packages;

buildPythonPackage rec {
  pname = "tt-flash";
  version = "main-01-31-24";

  src = pkgs.fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-flash";
    rev = "09db4103efe0c63adc3ea6e61f19eac7eb06d46f";
    hash = "sha256-fNAP/XuPdn51TtBEelSjh93NgMiyP1j6RqjnrzX9dc4=";
  };

  format = "pyproject";

  # patches = [ ./pyproject.patch ./log.patch ];

  propagatedBuildInputs = [
    setuptools
    pyyaml
    pyluwen
    tabulate
  ]; # requests textual black distro elasticsearch jsons pydantic psutil pyyaml pyluwen importlib-resources pkgs.pre-commit tools-common ];
}
