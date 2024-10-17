{ lib, stdenv, fetchFromGitHub, cmake }:

stdenv.mkDerivation rec {
  pname = "libyaml-cpp";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "jbeder";
    repo = "yaml-cpp";
    rev = "yaml-cpp-${version}";
    sha256 = "16lclpa487yghf9019wymj419wkyx4795wv9q7539hhimajw9kpb";
  };

  # implement https://github.com/jbeder/yaml-cpp/commit/52a1378e48e15d42a0b755af7146394c6eff998c
  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace 'option(YAML_BUILD_SHARED_LIBS "Build Shared Libraries" OFF)' \
                'option(YAML_BUILD_SHARED_LIBS "Build yaml-cpp shared library" ''${BUILD_SHARED_LIBS})'
  '';

  nativeBuildInputs = [ cmake ];

  cmakeFlags = [ "-DBUILD_SHARED_LIBS=ON" "-DYAML_CPP_BUILD_TESTS=OFF" ];
}
