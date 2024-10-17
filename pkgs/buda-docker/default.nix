{
  dockerTools,
  callPackage,
  git,
}:

let
  budaDocker = dockerTools.pullImage {
    imageName = "ghcr.io/tenstorrent/tt-buda/ubuntu-22-04-amd64/wh_b0";
    imageDigest = "sha256:3a6f84ed355c8738432737f6498745c4bee235b871e97608394e29e396ff6925";
    sha256 = "1vx7v9yx211dibshzgzz9zwm9xgkfj25iabplff19hx687w0n3sz";
    finalImageName = "ghcr.io/tenstorrent/tt-buda/ubuntu-22-04-amd64/wh_b0";
    finalImageTag = "v0.19.3";
  };

  #nixDocker = dockerTools.pullImage {
  #  imageName = "nixpkgs/nix-flakes";
  #  imageDigest = "sha256:cab18b64d25e4bc30415758d6e2f6bc05ecf6ae576092c0cf407b1cebb1ea0e5";
  #  sha256 = "0v4npm2h4z0k3y0h75zsk3q589vhris76g4vg5gkjlfbg16c822j";
  #  finalImageName = "nixpkgs/nix-flakes";
  #  finalImageTag = "latest";
  #};

  nixDocker = callPackage ../../docker/nix/default.nix {
    fromImage = budaDocker;

    # gitMinimal still ships with perl and python
    gitReallyMinimal =
      (git.override {
        perlSupport = false;
        pythonSupport = false;
        withManual = false;
        withpcre2 = false;
      }).overrideAttrs
        (_: {
          # installCheck is broken when perl is disabled
          doInstallCheck = false;
        });
  };
in
budaDocker
