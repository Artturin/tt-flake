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
        kernel = pkgs.linux_latest;
        kmd = import ./pkgs/kmd { inherit pkgs kernel; };
        sfpi = import ./pkgs/sfpi { inherit pkgs; };
        luwen = import ./pkgs/luwen { inherit pkgs; };
        common = import ./pkgs/common { inherit pkgs; };
        flash = import ./pkgs/flash {
          inherit pkgs;
          pyluwen = luwen.pyluwen_0_1;
          tools-common = common;
        };
        smi = import ./pkgs/smi {
          inherit pkgs;
          pyluwen = luwen.pyluwen;
          tools-common = common;
        };
        umd = import ./pkgs/umd { inherit pkgs; };
      in
      {
        packages = {
          kmd = kmd.kmd;
          udev-rules = kmd.udev-rules;
          kmd-test = kmd.test;
          sfpi = sfpi.sfpi;
          tt-gcc = sfpi.tt-gcc;
          smi = smi;
          luwen = luwen.luwen;
          pyluwen = luwen.pyluwen;
          tools-common = common;
          flash = flash;
          umd = umd;
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
