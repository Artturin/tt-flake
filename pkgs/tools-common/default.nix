{ fetchFromGitHub, python3Packages }:

let
  # Can be unpinned once https://github.com/tenstorrent/tt-tools-common/blob/main/pyproject.toml#L32
  # is v1
  textual_0_82 = python3Packages.textual.overridePythonAttrs (old: rec {
    version = "0.82.0";
    src = fetchFromGitHub {
      owner = "Textualize";
      repo = "textual";
      rev = "refs/tags/v${version}";
      hash = "sha256-belpoXQ+CkTchK+FjI/Ur8v4cNgzX39xLdNfPCwaU6E=";
    };
    disabledTests = old.disabledTests ++ [
      "test_selection"
    ];
  });
in

python3Packages.buildPythonPackage rec {
  pname = "tools-common";
  # https://github.com/tenstorrent/tt-smi/blob/main/pyproject.toml#L31
  version = "1.4.11";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-tools-common";
    rev = "refs/tags/v${version}";
    sha256 = "sha256-Q5GpT6B3pamY6bUjPbvNJ11npiR4q/6QMjRxovQ/MZ0=";
  };

  format = "pyproject";

  nativeBuildInputs = with python3Packages; [ pythonRelaxDepsHook ];

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

  propagatedBuildInputs = with python3Packages; [
    setuptools
    distro
    elasticsearch
    psutil
    pyyaml
    rich
    textual_0_82
    requests
    jsons
    tqdm
    pydantic
  ];

  pythonImportsCheck = [
    "tt_tools_common"
  ];

  passthru = {
    textual = textual_0_82;
  };
}
