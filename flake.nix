{
  description = "Tenstorrent software stack.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs =
    inputs:
    let
      inherit (inputs) self;
      inherit (inputs.nixpkgs) lib;
    in
    inputs.utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system};
        scope = lib.makeScope pkgs.newScope (
          self:
          let
            inherit (self) callPackage;
            # so `kmd.kmd` gets its own `.override`
            callPackages = lib.callPackagesWith (pkgs // self);
            kernel = pkgs.linux_latest;
          in
          {
            kmd = callPackages ./pkgs/kmd { inherit kernel; };
            sfpi = callPackages ./pkgs/sfpi { };
            luwen = (callPackage ./pkgs/luwen { }).luwen;
            pyluwen = (callPackage ./pkgs/luwen { }).pyluwen;
            tools-common = callPackage ./pkgs/tools-common { };
            system-tools = callPackage ./pkgs/system-tools { };
            flash = callPackage ./pkgs/flash { };
            smi = callPackage ./pkgs/smi { };
            umd = callPackage ./pkgs/umd { };
            metal = callPackage ./pkgs/metal { };

          }
        );
      in
      {
        packages = {
          kmd = scope.kmd.kmd;
          udev-rules = scope.kmd.udev-rules;
          kmd-test = scope.kmd.test;
          sfpi = scope.sfpi.sfpi;
          sfpi-prebuilt = scope.sfpi.prebuilt;
          tt-gcc = scope.sfpi.tt-gcc;
          smi = scope.smi;
          luwen = scope.luwen;
          pyluwen = scope.pyluwen;
          tools-common = scope.tools-common;
          system-tools = scope.system-tools;
          flash = scope.flash;
          umd = scope.umd;
          metal = scope.metal;
          default = self.packages.${system}.smi;
        };

        checks = {
          simple =
            pkgs.runCommand "test"
              {
                # Goes up to 7
                NIX_DEBUG = 0;
              }
              ''
                mkdir -p $out
                ${self.packages.${system}.tt-gcc}/bin/riscv32-unknown-elf-gcc ${./tests/test.c} -o $out/test
                ${self.packages.${system}.tt-gcc}/bin/riscv32-unknown-elf-gcc -mblackhole ${./tests/test.c} -o $out/test-wormhole
              '';
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    )
    // {
      # TODO: Add overlay
      nixosModules = {
        tt-module =
          { config, pkgs, ... }:
          {
            boot = {
              extraModulePackages = [
                ((pkgs.tt-kmd or self.packages.${pkgs.hostPlatform.system}.kmd).override {
                  kernel = config.boot.kernelPackages.kernel;
                })
              ];
              kernelParams = [
                "iommu=pt"
              ];
              kernelModules = [ "tenstorrent" ];
            };
            systemd = {
              # https://github.com/NixOS/nixpkgs/issues/81138
              services.tenstorrent-hugepages.wantedBy = [ "sysinit.target" ];
              # Define https://github.com/tenstorrent/tt-system-tools/blob/29ba4dc6049eef3cee4314c53720417823ffc667/dev-hugepages%5Cx2d1G.mount
              # because it has bad start ordering relations with tenstorrent-hugepages.service
              # or it may be that the `wantedBy` does not work correctly in mounts like it does't work in serices.
              mounts = [
                {
                  description = "Mount hugepages at /dev/hugepages-1G for Tenstorrent ASICs";
                  what = "hugetlbfs";
                  where = "/dev/hugepages-1G";
                  type = "hugetlbfs";
                  options = "pagesize=1G,mode=0777,nosuid,nodev";
                  wantedBy = [ "sysinit.target" ];
                  after = [ "tenstorrent-hugepages.service" ];
                  unitConfig = {
                    DefaultDependencies = false;
                    ConditionPathExists = "/sys/kernel/mm/hugepages/hugepages-1048576kB";
                    ConditionCapability = "CAP_SYS_ADMIN";
                  };
                }
              ];
              packages = [
                (pkgs.tt-system-tools or self.packages.${pkgs.hostPlatform.system}.system-tools)
              ];
            };
            services.udev = {
              packages = [ (pkgs.tt-udev-rules or self.packages.${pkgs.hostPlatform.system}.udev-rules) ];
              # NOTE: passing just the group does not work currently for docker so unneeded for now so use the udev-rules package for now
              # TT_METAL_HOME=$PWD docker run -v $PWD:/host --workdir /host -v /dev/hugepages-1G:/dev/hugepages-1G -v /dev/tenstorrent:/dev/tenstorrent -u :994 -v /etc/group:/etc/group:ro -it tt-metal bash
              # extraRules = ''
              #   KERNEL=="tenstorrent*", MODE="0666", OWNER="root", GROUP="tenstorrent"
              # '';
            };
            # users.groups.tenstorrent = { };

          };
      };
    };
}
