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
            luwen = callPackage ./pkgs/luwen { };
            tools-common = callPackage ./pkgs/tools-common { };
            system-tools = callPackage ./pkgs/system-tools { };
            flash = callPackage ./pkgs/flash {
              pyluwen = self.luwen.pyluwen_0_1;
            };
            smi = callPackage ./pkgs/smi {
              pyluwen = self.luwen.pyluwen;
            };
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
          tt-gcc = scope.sfpi.tt-gcc;
          smi = scope.smi;
          luwen = scope.luwen.luwen;
          pyluwen = scope.luwen.pyluwen;
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
    );
}
